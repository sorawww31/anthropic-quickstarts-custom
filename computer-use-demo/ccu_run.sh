#!/bin/bash

# .envファイルから環境変数を読み込み
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
    echo ".envファイルから環境変数を読み込みました"
else
    echo "エラー: .envファイルが見つかりません"
    echo ".envファイルを作成し、ANTHROPIC_API_KEY=your_api_key_here の形式でAPIキーを設定してください"
fi

# APIキーが設定されているかチェック
if [ -z "$ANTHROPIC_API_KEY" ]; then
    echo "エラー: ANTHROPIC_API_KEYが設定されていません"
    echo ".envファイルにANTHROPIC_API_KEY=your_api_key_here を追加してください"
fi

echo "Dockerコンテナを起動中..."
docker run \
    -e ANTHROPIC_API_KEY=$ANTHROPIC_API_KEY \
    -v $HOME/.anthropic:/home/computeruse/.anthropic \
    -p 5900:5900 \
    -p 8501:8501 \
    -p 6080:6080 \
    -p 8080:8080 \
    -it ghcr.io/anthropics/anthropic-quickstarts:computer-use-demo-latest\
    --rm