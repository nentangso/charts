# Helm Charts Release Guide

Hướng dẫn release Helm charts tự động với GitHub Actions.

## Cách sử dụng

### Phương pháp 1: Sử dụng script (Khuyến nghị)

```bash
# Release spring-boot-app
./scripts/release.sh spring-boot-app 0.2.4

# Release webapp
./scripts/release.sh webapp 0.1.7
```

### Phương pháp 2: Tạo tag thủ công

```bash
# Tạo tag cho spring-boot-app
git tag -a spring-boot-app-0.2.4 -m "Release spring-boot-app v0.2.4"
git push origin spring-boot-app-0.2.4

# Tạo tag cho webapp
git tag -a webapp-0.1.7 -m "Release webapp v0.1.7"
git push origin webapp-0.1.7
```

### Phương pháp 3: Sử dụng GitHub UI

1. Vào tab "Actions" trong repository
2. Chọn workflow "Release Helm Charts"
3. Click "Run workflow"
4. Chọn chart name và nhập version
5. Click "Run workflow"

## Quy trình tự động

Khi trigger release, GitHub Action sẽ thực hiện các bước sau:

1. **Tạo draft release** với tên tag tương ứng
2. **Package Helm chart** sử dụng `helm package`
3. **Upload artifact** (file .tgz) vào release
4. **Cập nhật Helm repository index** (index.yaml) với link artifact
5. **Commit và push** các thay đổi
6. **Publish release** (chuyển từ draft sang published)

## Cấu trúc tag

- Format: `<chart-name>-<version>`
- Ví dụ: `spring-boot-app-0.2.4`, `webapp-0.1.7`

## Charts có sẵn

- `spring-boot-app`: Chart cho Spring Boot applications
- `webapp`: Chart cho web applications (React, Vue, etc.)

## Lưu ý

- Version phải tuân theo format semantic versioning (x.y.z)
- Tag name phải unique và chưa tồn tại
- Script sẽ tự động validate input trước khi tạo tag
- GitHub Action cần quyền `contents: write` và `packages: write`

## Troubleshooting

### Lỗi "Tag already exists"
```bash
# Xóa tag local
git tag -d spring-boot-app-0.2.4

# Xóa tag remote
git push origin :refs/tags/spring-boot-app-0.2.4
```

### Lỗi "Invalid version format"
- Đảm bảo version theo format x.y.z (ví dụ: 0.2.4, 1.0.0)

### Lỗi "Chart directory not found"
- Kiểm tra chart có tồn tại trong thư mục `nentangso/`
- Đảm bảo Chart.yaml có trong thư mục chart

## Monitoring

Theo dõi tiến trình release tại:
- GitHub Actions: `https://github.com/nentangso/charts/actions`
- Releases: `https://github.com/nentangso/charts/releases`
