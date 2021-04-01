## 키페어 등록
resource "aws_key_pair" "web_admin" {
  key_name = "web_admin"
  public_key = file("~/.ssh/web_admin.pub")
}

## 보안그룹 설정
resource "aws_security_group" "ssh" {
  name = "allow_ssh_from_all"
  description = "Allow SSH port from all"
  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  }
}

## VPC의 기본(default) 시큐리티 그룹 불러오기
data "aws_security_group" "default" {
  name = "default"
}

## EC2 인스턴스를 정의하는 리소스 정의
resource "aws_instance" "web" {
  ami = "ami-0a93a08544874b3b7" # amzn2-ami-hvm-2.0.20200207.1-x86_64-gp2
  instance_type = "t2.micro"
  key_name = aws_key_pair.web_admin.key_name
  vpc_security_group_ids = [
    aws_security_group.ssh.id,
    data.aws_security_group.default.id
  ]
}

## RDS 인스턴스 정의
resource "aws_db_instance" "web_db" {
  instance_class = "db.t2.micro"  # 인스턴스 타입(RDS 인스턴스 타입만 사용 가능)
  allocated_storage = 8 # 할당량 용량(기가바이트 단위)
  engine = "mysql"  # 데이터베이스 엔진
  engine_version = "5.6.35" # 데이터베이스 엔진 버전
  username = "admin"  # 계정 이름
  password = "admin!234" # 비밀번호
  skip_final_snapshot = true  # 인스턴스 제거 시 최종 스냅샷을 만들지 않고 제거함.
}