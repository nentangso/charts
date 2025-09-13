# Nentangso Helm Charts

Repository chứa các Helm charts được tạo và duy trì bởi Nentangso team.

## Charts có sẵn

### spring-boot-app
Chart để deploy Spring Boot applications với các tính năng:
- Auto-scaling với HPA
- JMX monitoring
- Redis integration (optional)
- Ingress support
- TLS/SSL support

### webapp
Chart để deploy web applications (React, Vue, Angular, etc.) với:
- Nginx reverse proxy
- Static file serving
- Ingress support
- TLS/SSL support

## Sử dụng

### Thêm repository
```bash
helm repo add nentangso https://nentangso.github.io/charts
helm repo update
```

### Cài đặt chart
```bash
# Cài đặt spring-boot-app
helm install my-app nentangso/spring-boot-app

# Cài đặt webapp
helm install my-webapp nentangso/webapp
```

### Cài đặt với custom values
```bash
# Tạo file values.yaml
helm show values nentangso/spring-boot-app > my-values.yaml

# Chỉnh sửa values.yaml theo nhu cầu
# Cài đặt với custom values
helm install my-app nentangso/spring-boot-app -f my-values.yaml
```

## Development

### Validate charts locally
```bash
# Validate tất cả charts
./scripts/validate.sh

# Validate chart cụ thể
./scripts/validate.sh spring-boot-app
```

### Release charts
Xem [RELEASE.md](RELEASE.md) để biết cách release charts.

## Cấu trúc repository

```
charts/
├── .github/workflows/          # GitHub Actions workflows
├── nentangso/                  # Charts source code
│   ├── spring-boot-app/        # Spring Boot chart
│   └── webapp/                 # Web app chart
├── scripts/                    # Helper scripts
│   ├── release.sh              # Release script
│   └── validate.sh             # Validation script
├── index.yaml                  # Helm repository index
└── *.tgz                       # Packaged charts
```

## Contributing

1. Fork repository
2. Tạo feature branch
3. Thực hiện thay đổi
4. Validate charts: `./scripts/validate.sh`
5. Tạo Pull Request

## License

Apache-2.0
