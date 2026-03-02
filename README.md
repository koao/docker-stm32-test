# docker-stm32-test

STM32 ファームウェアプロジェクトのユニットテスト・コードカバレッジ測定用 Docker イメージ。

GCC + CMake + lcov を含む軽量な Ubuntu ベースのビルド環境を提供する。
STM32 のクロスコンパイルツールは含まない（ホスト向けユニットテスト専用）。

## Docker Hub

```
docker pull koao/stm32-test:latest
```

https://hub.docker.com/r/koao/stm32-test

## イメージ内容

| ツール | バージョン | 用途 |
|--------|-----------|------|
| Ubuntu | 22.04 LTS | ベース OS |
| GCC (build-essential) | Ubuntu 22.04 同梱 | C/C++ コンパイル |
| CMake | 3.28.6 | ビルド構成 |
| lcov | 1.14-2 | GCC コードカバレッジ測定 |
| genhtml | lcov 同梱 | カバレッジ HTML レポート生成 |

> **Note:** lcov 1.14-2 を使用している理由は、Ubuntu 22.04 の GCC バージョンとの互換性を確保するため。

## 使い方

テスト対象プロジェクトのルートディレクトリで実行する。
ソースコードをボリュームマウントし、コンテナ内でビルド・テストを行う。

### テスト実行

```bash
docker run --rm -v "$(pwd):/workspace" koao/stm32-test:latest bash -c "
  cd /workspace/path/to/tests &&
  cmake -B build -DCMAKE_BUILD_TYPE=Debug &&
  cmake --build build &&
  ctest --test-dir build -C Debug --output-on-failure
"
```

### カバレッジ測定付きテスト

```bash
docker run --rm -v "$(pwd):/workspace" koao/stm32-test:latest bash -c "
  cd /workspace/path/to/tests &&
  cmake -B build -DCMAKE_BUILD_TYPE=Debug -DENABLE_COVERAGE=ON &&
  cmake --build build &&
  ctest --test-dir build -C Debug --output-on-failure
"
```

### カバレッジ HTML レポート生成

```bash
docker run --rm -v "$(pwd):/workspace" koao/stm32-test:latest bash -c "
  cd /workspace/path/to/tests &&
  lcov --capture --directory build --output-file coverage.info &&
  lcov --remove coverage.info '/usr/*' '*/tests/*' '*/googletest/*' '*/CMakeFiles/*' --output-file coverage.info &&
  genhtml coverage.info --output-directory coverage_report --show-details --legend --demangle-cpp
"
```

## GitHub Actions での利用例

```yaml
jobs:
  test:
    runs-on: ubuntu-22.04
    steps:
    - uses: actions/checkout@v4

    - name: Pull test image
      run: docker pull koao/stm32-test:latest

    - name: Run tests
      run: |
        docker run --rm \
          -v "${{ github.workspace }}:/workspace" \
          -w /workspace/path/to/tests \
          koao/stm32-test:latest bash -c "
            cmake -B build -DCMAKE_BUILD_TYPE=Debug -DENABLE_COVERAGE=ON &&
            cmake --build build &&
            ctest --test-dir build -C Debug --output-on-failure
          "
```

## タグ・バージョニング

| タグ | 説明 |
|------|------|
| `latest` | 常に最新（main ブランチの HEAD） |
| `1.0.0` 等 | Git タグ `v1.0.0` に対応する固定バージョン |

特定バージョンに固定したい場合:
```
docker pull koao/stm32-test:1.0.0
```

## このリポジトリの開発

### ビルドの仕組み

GitHub Actions（`.github/workflows/publish.yml`）が自動でビルド・プッシュを行う:

- `main` ブランチへの push → `latest` タグを更新
- `v*` パターンのタグ push → セマンティックバージョンタグ + `latest` を更新
- 手動実行（`workflow_dispatch`）も可能

### 必要なシークレット

GitHub リポジトリの Settings > Secrets and variables > Actions に以下を設定:

| シークレット名 | 内容 |
|---|---|
| `DOCKERHUB_USERNAME` | Docker Hub のユーザー名 |
| `DOCKERHUB_TOKEN` | Docker Hub のアクセストークン |

Docker Hub アクセストークンは https://hub.docker.com/settings/security で作成できる。

### ローカルでのビルド・テスト

```bash
# イメージをローカルビルド
docker build -t stm32-test .

# ビルドしたイメージの動作確認
docker run --rm stm32-test cmake --version
docker run --rm stm32-test gcc --version
docker run --rm stm32-test lcov --version
```
