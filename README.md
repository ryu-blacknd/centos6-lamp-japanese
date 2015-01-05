centos6-lamp-japanese
=====================

CentOS 6 にLAMP環境を構築し、さらに OpenJDK と Tomcat の環境も構築するスクリプトです。

開発用のサーバを想定しており、GitHub クローンの GitBucket と、自動デプロイ用に Jenkins も導入します。

Tomcat と Apache は AJP で通信し、外からのアクセスは Apache が受け持ちます。

**詳細はブログの記事を御覧ください。**

http://blacknd.com/linux-server/centos7-gitbucket-jenkins-auto-deploy/

※記事の末尾に CentOS 6 への対応を書いてあります。

## 導入方法

適当なディレクトリ (例：~/repos) を作成し、そこで作業します。

~~~~
# yum install -y git
# git clone https://github.com/ryu-blacknd/centos6-lamp-japanese.git
~~~~

※この Git はバージョンが古いため、スクリプトで置き換えられます。

そしてスクリプトを実行します。

~~~~
# cd centos6-lamp-japanese
# chmod +x setup.sh
# ./setup.sh
~~~~

作業が完了したら再起動してください。
