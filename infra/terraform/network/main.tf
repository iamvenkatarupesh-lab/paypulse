# ============================================================================
# DATA: Discover available AZs in the chosen region
# Avoids hardcoding "us-east-1a" etc. — works in any region
# ============================================================================
data "aws_availability_zones" "available" {
  state = "available"
}

# ============================================================================
# VPC — the private network container
# enable_dns_* are required for EKS/RDS service discovery to work
# ============================================================================
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# ============================================================================
# INTERNET GATEWAY — lets public subnets talk to the internet
# Free. One per VPC. Doesn't do NAT — just bridges VPC <-> internet.
# ============================================================================
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

# ============================================================================
# PUBLIC SUBNETS — one per AZ
# map_public_ip_on_launch = true: any EC2 launched here gets a public IP
# EKS-discovery tags so the cluster knows these are for public LBs
# ============================================================================
resource "aws_subnet" "public" {
  count = var.az_count

  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name                                            = "${var.project_name}-public-${data.aws_availability_zones.available.names[count.index]}"
    Tier                                            = "public"
    "kubernetes.io/role/elb"                        = "1"
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
  }
}

# ============================================================================
# PRIVATE SUBNETS — one per AZ
# No public IP. EKS workers and RDS will live here.
# Tags signal EKS to use these for internal LBs
# ============================================================================
resource "aws_subnet" "private" {
  count = var.az_count

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name                                            = "${var.project_name}-private-${data.aws_availability_zones.available.names[count.index]}"
    Tier                                            = "private"
    "kubernetes.io/role/internal-elb"               = "1"
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
  }
}

# ============================================================================
# ELASTIC IP — static public IP for the NAT Gateway
# domain = "vpc" since EC2-Classic is dead
# ============================================================================
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "${var.project_name}-nat-eip"
  }

  # EIP allocation requires the IGW to exist in the VPC
  depends_on = [aws_internet_gateway.main]
}

# ============================================================================
# NAT GATEWAY — single, in us-east-1a (cost optimization choice 1A)
# ALL private subnets route through this regardless of AZ.
# ~$0.045/hour while running. The biggest cost driver in this stack.
# ============================================================================
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id # First public subnet (us-east-1a)

  tags = {
    Name = "${var.project_name}-nat"
  }

  depends_on = [aws_internet_gateway.main]
}

# ============================================================================
# PUBLIC ROUTE TABLE — 0.0.0.0/0 → IGW
# Any traffic going anywhere except the VPC itself goes out via IGW
# ============================================================================
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.project_name}-public-rt"
    Tier = "public"
  }
}

# Bind each public subnet to the public route table
resource "aws_route_table_association" "public" {
  count = var.az_count

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# ============================================================================
# PRIVATE ROUTE TABLE — 0.0.0.0/0 → NAT Gateway
# All private subnets share ONE route table since we have one NAT
# (Production HA: one route table per AZ pointing to that AZ's NAT)
# ============================================================================
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name = "${var.project_name}-private-rt"
    Tier = "private"
  }
}

# Bind each private subnet to the private route table
resource "aws_route_table_association" "private" {
  count = var.az_count

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}
