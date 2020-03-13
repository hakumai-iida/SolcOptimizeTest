## はじめに  
**iOS** で **Ethereum** ブロックチェーンへアクセスし、**solc** のバージョンと最適化指定により、コントラクトのガス消費がどうなるかをテストするアプリです。  

イーサリアムクライアントとして [**web3swift**](https://github.com/matter-labs/web3swift)  ライブラリを利用させていただいております。     

----
## 手順  
### ・**CocoaPods** の準備
　ターミナルを開き下記のコマンドを実行します  
　`$ sudo gem install cocoapods`  

### ・**web3swift** のインストール
　ターミナル上で **SolcOptimizeTest** フォルダ(※ **Podfile** のある階層)へ移動し、下記のコマンドを実行します  
　`$ pod install`  
　
### ・ワークスペースのビルド
　**SolcOptimizeTest.xcworkspace** を **Xcode** で開いてビルドします  
　（※間違えて **SolcOptimizeTest.xcodeproj** のほうを開いてビルドするとエラーになるのでご注意ください）
　
### ・動作確認
　**Xcode** から **iOS** 端末にてアプリを起動し、画面をタップするとテストが実行されます  
　**Xcode** のデバッグログに下記のようなログが表示されるのでソースコードと照らし合わせてご確認下さい  

---

> @-----------------------------  
> @ TestSolcOptimize: start...  
> @-----------------------------  
> @------------------  
> @ setTarget  
> @------------------  
> @ target: rinkeby  
> @------------------  
> @ setKeystore  
> @------------------  
> @ loadKeystoreJson: json= {"version":3,"id":"27b6bb1e-c5cd-4ded-ba72-401b29303294","crypto":{"ciphertext":"a95bda6dbff539f3e4b5e679af42670f72c6a86206bd8b56d51b7b4f06a742c8","cipherparams":{"iv":"6b8c1e0e7631b1d02e4d549d5a3af732"},"kdf":"scrypt","kdfparams":{"r":6,"p":1,"n":4096,"dklen":32,"salt":"bd4854af98da1014c22f260b6c3e323ea2ef3d9b9f081ed638285b12059ae786"},"mac":"78a8c39cffca93651a8f7cc50344b5bd20051979ed8f7d6b36cc94a99657fbe7","cipher":"aes-128-ctr"},"address":"0x961365b57e2a25bfc66918ed0881222c2b757b49"}  
> @ loadKeystore: result= true  
> @ CURRENT KEYSTORE  
> @ ethereumAddress: 0x961365b57E2A25Bfc66918ED0881222c2B757B49  
> @------------------  
> @ checkBalance  
> @------------------  
> @ balance: 68152443000000000 wei  
> @-----------------------------------  
> @ solc: 0.5.12, optmize: runs_1  
> @-----------------------------------  
> @ total kitties: 219  
> @ createKitty: 0x3f967c7e2cbc269b88d71ccd39d73ed0e340253f5a652a95bb75226861577424  
> @-----------------------------------  
> @ solc: 0.5.12, optmize: runs_200  
> @-----------------------------------  
> @ total kitties: 219  
> @ createKitty: 0x7c0a2e7b9db85ba0c1fc0e37c763674aefee90a2ce1745fde4ec09bf8dc4028a  
> @-----------------------------------  
> @ solc: 0.5.12, optmize: runs_2000  
> @-----------------------------------  
> @ total kitties: 219  
> @ createKitty: 0xf55ccc017d60a13080adf8f3dc4bcfd80a02bba02723369dfdb4cda37b5db25d  
> @-----------------------------------  
> @ solc: 0.5.12, optmize: non  
> @-----------------------------------  
> @ total kitties: 219  
> @ createKitty: 0x1e78e1e1fb75e0784b2ce41e3fe85958414b5c37fb3fe9bf38a2f27eb5291246  
> @-----------------------------------  
> @ solc: 0.4.25, optmize: runs_1  
> @-----------------------------------  
> @ total kitties: 219  
> @ createKitty: 0x750f4bb12ebd174bebe0a68f94d3a2bb6f47d238c3e959d5beaad5ec5719a19c  
> @-----------------------------------  
> @ solc: 0.4.25, optmize: runs_200  
> @-----------------------------------  
> @ total kitties: 219  
> @ createKitty: 0xa940f0cf176504d8cf44d623983e83772ebb9dc62facc1ef4e44a66a09cc9544  
> @-----------------------------------  
> @ solc: 0.4.25, optmize: runs_2000  
> @-----------------------------------  
> @ total kitties: 219  
> @ createKitty: 0xf0a505445cc589e7f35aad24bed88ae6b0fc0ae878b84759aa2214aa01440882  
> @-----------------------------------  
> @ solc: 0.4.25, optmize: non  
> @-----------------------------------  
> @ total kitties: 219  
> @ createKitty: 0xe30311b9e0bd93b81478b894a3d64ee906b6d6af993993cb0ab583ec4cf66bf6  
> @-----------------------------  
> @ TestSolcOptimize: finished  
> @-----------------------------  

---

### テスト内容
最適化のテストは、「最適化 **有** の  **runs=1**」、「最適化 **有** の **runs=200**」、「最適化 **有** の  **runs=2000**」、「最適化 **無**」の４パターンに対し、**solc** のバージョン「**0.5.12**」、「**0.4.25**」の２つの組み合わせでテストしています

## 補足

テスト用のコードが **TestSolcOptimize.swift**、簡易ヘルパーが **Web3Helper.swift**、 イーサリアム上のコントラクトに対応するコードが、各 **CompileOptX.swift**となります。  

その他のソースファイルは **Xcode** の **Game** テンプレートが吐き出したコードそのまんまとなります。ただし、画面タップでテストを呼び出すためのコードが **GameScene.swift** に２行だけ追加してあります。

**sol/CompileOptX.sol** が各コントラクトのソースとなります。**Xcode** では利用していません。

テストが開始されると、デフォルトで **Rinkeby** テストネットへ接続します。  

初回の呼び出し時であればアカウントを作成し、その内容をアプリのドキュメント領域に **key.json** の名前で出力します。二度目以降の呼び出し時は **key.json** からアカウント情報を読み込んで利用します。  

コントラクトへの書き込みテストは、対象のアカウントに十分な残高がないとエラーとなります。**Xcode** のログにアカウント情報が表示されるので、適宜、対象のアカウントに送金してテストしてください。
  
----
## メモ
　2020年3月13日の時点で、下記の環境で動作確認を行なっています。  

#### 実装環境
　・**macOS Mojave 10.14.4**  
　・**Xcode 11.3.1(11C504)**

#### 確認端末
　・**iPad**(第六世代) **iOS 12.2**  
