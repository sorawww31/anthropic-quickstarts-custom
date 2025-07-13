# Anthropic Computer Use デモ

> [!NOTE]
> 新しいClaude 4モデルのサポートを搭載！最新のClaude 4 Sonnet（claude-sonnet-4-20250514）がデフォルトモデルとなり、Claude 4 Opus（claude-opus-4-20250514）も利用可能です。これらのモデルは、従来のstr_replace_editorツールに代わる更新されたstr_replace_based_edit_toolを含む次世代機能を提供します。より合理化された体験のため、この最新バージョンではundo_editコマンドが削除されました。

> [!CAUTION]
> Computer useはベータ機能です。Computer useは、標準的なAPI機能やチャットインターフェースとは異なる固有のリスクを伴うことにご注意ください。これらのリスクは、computer useを使用してインターネットと相互作用する際に高まります。リスクを最小限に抑えるため、以下の予防措置を検討してください：
>
> 1. 直接的なシステム攻撃や事故を防ぐため、最小限の権限を持つ専用の仮想マシンまたはコンテナを使用する。
> 2. 情報窃取を防ぐため、アカウントログイン情報などの機密データへのモデルアクセスを避ける。
> 3. 悪意のあるコンテンツへの露出を減らすため、許可リストのドメインにインターネットアクセスを制限する。
> 4. 実世界で意味のある結果をもたらす可能性のある決定や、Cookieの受け入れ、金融取引の実行、利用規約への同意など、肯定的な同意が必要なタスクについては、人間に確認を求める。
>
> 状況によっては、Claudeはユーザーの指示と矛盾していても、コンテンツ内にある指示に従うことがあります。例えば、ウェブページの指示や画像に含まれる指示がユーザーの指示を上書きしたり、Claudeにミスを犯させたりする可能性があります。プロンプトインジェクションに関連するリスクを避けるため、Claudeを機密データやアクションから隔離する予防措置を講じることをお勧めします。
>
> 最後に、エンドユーザーに関連するリスクを知らせ、独自の製品でcomputer useを有効にする前に同意を得てください。

このリポジトリは、ClaudeでのComputer useを始める際に役立ち、以下の参考実装を提供します：

- 必要なすべての依存関係を含むDockerコンテナを作成するためのビルドファイル
- Anthropic API、Bedrock、またはVertexを使用してClaude 3.5 Sonnet、Claude 3.7 Sonnet、Claude 4 Sonnet、Claude 4 Opusモデルにアクセスするcomputer useエージェントループ
- Anthropic定義のcomputer useツール
- エージェントループと相互作用するためのStreamlitアプリ

モデルレスポンス、API自体、またはドキュメントの品質に関するフィードバックを[このフォーム](https://forms.gle/BT1hpBrqDPDUrCqo7)からお寄せください。皆様からのご意見をお待ちしています！

> [!IMPORTANT]
> この参考実装で使用されているベータAPIは変更される可能性があります。最新の情報については、[APIリリースノート](https://docs.anthropic.com/en/release-notes/api)を参照してください。

> [!IMPORTANT]
> コンポーネントは弱く分離されています：エージェントループはClaudeによって制御されるコンテナ内で実行され、一度に一つのセッションでのみ使用でき、必要に応じてセッション間で再起動またはリセットする必要があります。

## クイックスタート：Dockerコンテナの実行

### Anthropic API

> [!TIP]
> APIキーは[Anthropic Console](https://console.anthropic.com/)で確認できます。

```bash
export ANTHROPIC_API_KEY=%your_api_key%
docker run \
    -e ANTHROPIC_API_KEY=$ANTHROPIC_API_KEY \
    -v $HOME/.anthropic:/home/computeruse/.anthropic \
    -p 5900:5900 \
    -p 8501:8501 \
    -p 6080:6080 \
    -p 8080:8080 \
    -it ghcr.io/anthropics/anthropic-quickstarts:computer-use-demo-latest
```

コンテナが実行されたら、インターフェースへの接続方法については以下の[デモアプリへのアクセス](#デモアプリへのアクセス)セクションを参照してください。

### Bedrock

> [!TIP]
> BedrockでClaude 3.7 Sonnetを使用するには、まず[モデルアクセスをリクエスト](https://docs.aws.amazon.com/bedrock/latest/userguide/model-access-modify.html)する必要があります。

BedrockでClaudeを使用するための適切な権限を持つAWS認証情報を渡す必要があります。
Bedrockでの認証にはいくつかのオプションがあります。詳細とオプションについては[boto3ドキュメント](https://boto3.amazonaws.com/v1/documentation/api/latest/guide/credentials.html#environment-variables)を参照してください。

#### オプション1：（推奨）ホストのAWS認証情報ファイルとAWSプロファイルを使用

```bash
export AWS_PROFILE=<your_aws_profile>
docker run \
    -e API_PROVIDER=bedrock \
    -e AWS_PROFILE=$AWS_PROFILE \
    -e AWS_REGION=us-west-2 \
    -v $HOME/.aws:/home/computeruse/.aws \
    -v $HOME/.anthropic:/home/computeruse/.anthropic \
    -p 5900:5900 \
    -p 8501:8501 \
    -p 6080:6080 \
    -p 8080:8080 \
    -it ghcr.io/anthropics/anthropic-quickstarts:computer-use-demo-latest
```

コンテナが実行されたら、インターフェースへの接続方法については以下の[デモアプリへのアクセス](#デモアプリへのアクセス)セクションを参照してください。

#### オプション2：アクセスキーとシークレットを使用

```bash
export AWS_ACCESS_KEY_ID=%your_aws_access_key%
export AWS_SECRET_ACCESS_KEY=%your_aws_secret_access_key%
export AWS_SESSION_TOKEN=%your_aws_session_token%
docker run \
    -e API_PROVIDER=bedrock \
    -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
    -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
    -e AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN \
    -e AWS_REGION=us-west-2 \
    -v $HOME/.anthropic:/home/computeruse/.anthropic \
    -p 5900:5900 \
    -p 8501:8501 \
    -p 6080:6080 \
    -p 8080:8080 \
    -it ghcr.io/anthropics/anthropic-quickstarts:computer-use-demo-latest
```

コンテナが実行されたら、インターフェースへの接続方法については以下の[デモアプリへのアクセス](#デモアプリへのアクセス)セクションを参照してください。

### Vertex

VertexでClaudeを使用するための適切な権限を持つGoogle Cloud認証情報を渡す必要があります。

```bash
docker build . -t computer-use-demo
gcloud auth application-default login
export VERTEX_REGION=%your_vertex_region%
export VERTEX_PROJECT_ID=%your_vertex_project_id%
docker run \
    -e API_PROVIDER=vertex \
    -e CLOUD_ML_REGION=$VERTEX_REGION \
    -e ANTHROPIC_VERTEX_PROJECT_ID=$VERTEX_PROJECT_ID \
    -v $HOME/.config/gcloud/application_default_credentials.json:/home/computeruse/.config/gcloud/application_default_credentials.json \
    -p 5900:5900 \
    -p 8501:8501 \
    -p 6080:6080 \
    -p 8080:8080 \
    -it computer-use-demo
```

コンテナが実行されたら、インターフェースへの接続方法については以下の[デモアプリへのアクセス](#デモアプリへのアクセス)セクションを参照してください。

この例では、Google Cloud Application Default CredentialsでVertexの認証を行う方法を示しています。
任意の認証情報ファイルを使用するために`GOOGLE_APPLICATION_CREDENTIALS`を設定することもできます。詳細については[Google Cloud認証ドキュメント](https://cloud.google.com/docs/authentication/application-default-credentials#GAC)を参照してください。

### デモアプリへのアクセス

コンテナが実行されたら、ブラウザで[http://localhost:8080](http://localhost:8080)を開いて、エージェントチャットとデスクトップビューの両方を含む統合インターフェースにアクセスしてください。

コンテナは、APIキーやカスタムシステムプロンプトなどの設定を`~/.anthropic/`に保存します。このディレクトリをマウントして、コンテナ実行間でこれらの設定を永続化してください。

その他のアクセスポイント：

- Streamlitインターフェースのみ：[http://localhost:8501](http://localhost:8501)
- デスクトップビューのみ：[http://localhost:6080/vnc.html](http://localhost:6080/vnc.html)
- 直接VNC接続：`vnc://localhost:5900`（VNCクライアント用）

## 画面サイズ

環境変数`WIDTH`と`HEIGHT`を使用して画面サイズを設定できます。例：

```bash
docker run \
    -e ANTHROPIC_API_KEY=$ANTHROPIC_API_KEY \
    -v $HOME/.anthropic:/home/computeruse/.anthropic \
    -p 5900:5900 \
    -p 8501:8501 \
    -p 6080:6080 \
    -p 8080:8080 \
    -e WIDTH=1920 \
    -e HEIGHT=1080 \
    -it ghcr.io/anthropics/anthropic-quickstarts:computer-use-demo-latest
```

[画像のリサイズ](https://docs.anthropic.com/en/docs/build-with-claude/vision#evaluate-image-size)に関連する問題を避けるため、[XGA/WXGA](https://en.wikipedia.org/wiki/Display_resolution_standards#XGA)以上の解像度でスクリーンショットを送信することはお勧めしません。
APIの画像リサイズ動作に依存すると、ツールで直接スケーリングを実装するよりもモデルの精度が低下し、パフォーマンスが低下します。このプロジェクトの`computer`ツール実装では、高解像度から推奨解像度へ画像と座標の両方をスケーリングする方法を示しています。

Computer useを自分で実装する際は、XGA解像度（1024x768）の使用をお勧めします：

- 高解像度の場合：画像をXGAにスケールダウンし、モデルがこのスケールされたバージョンと相互作用できるようにし、座標を元の解像度に比例してマッピングし直す。
- 低解像度または小さなデバイス（例：モバイルデバイス）の場合：1024x768に達するまでディスプレイエリアの周囲に黒いパディングを追加する。

## 開発

```bash
./setup.sh  # venvの設定、開発依存関係のインストール、pre-commitフックのインストール
docker build . -t computer-use-demo:local  # dockerイメージの手動ビルド（オプション）
export ANTHROPIC_API_KEY=%your_api_key%
docker run \
    -e ANTHROPIC_API_KEY=$ANTHROPIC_API_KEY \
    -v $(pwd)/computer_use_demo:/home/computeruse/computer_use_demo/ `# 開発用にローカルPythonモジュールをマウント` \
    -v $HOME/.anthropic:/home/computeruse/.anthropic \
    -p 5900:5900 \
    -p 8501:8501 \
    -p 6080:6080 \
    -p 8080:8080 \
    -it computer-use-demo:local  # ghcr.io/anthropics/anthropic-quickstarts:computer-use-demo-latestも使用可能
```

上記のdocker runコマンドは、dockerイメージ内にリポジトリをマウントし、ホストからファイルを編集できるようにします。Streamlitは既に自動リロードで設定されています。
