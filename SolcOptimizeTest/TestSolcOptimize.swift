//
//  TestSolcOptimize.swift
//  SolcOptimizeTest
//
//  Created by 飯田白米 on 2020/03/13.
//  Copyright © 2020 飯田白米. All rights reserved.
//

import Foundation
import UIKit
import BigInt
import web3swift

class TestSolcOptimize {
    //-------------------------
    // メンバー
    //-------------------------
    let helper: Web3Helper              // [web3swift]利用のためのヘルパー
    let keyFile: String                 // 直近に作成されたキーストアを保持するファイル
    let password: String                // アカウント作成時のパスワード
    let targetNet: Web3Helper.target    // 接続先
    var isBusy = false                  // 重複呼び出し回避用

    //-------------------------
    // イニシャライザ
    //-------------------------
    public init(){
        // ヘルパー作成
        self.helper = Web3Helper()
    
        // キーストアファイル
        self.keyFile = "key.json"

        // FIXME ご自身のパスワードで置き換えてください
        // メモ：このコードはテスト用なのでソース内にパスワードを書いていますが、
        //      公開を前提としたアプリを作る場合、ソース内にパスワードを書くことは大変危険です！
        self.password = "password"
                
        // FIXME ご自身のテストに合わせて接続先を変更してください
        self.targetNet = Web3Helper.target.rinkeby
    }

    //-------------------------
    // テストの開始
    //-------------------------
    public func test() {
        // テスト中なら無視
        if( self.isBusy ){
            print( "@ TestSolcOptimize: busy!" )
            return;
        }
        self.isBusy = true;
        
        // キュー（メインとは別のスレッド）で処理する
        let queue = OperationQueue()
        queue.addOperation {
            self.execTest()
            self.isBusy = false;
        }
    }

    //-------------------------
    // テストの開始
    //-------------------------
    func execTest() {
        print( "@-----------------------------" )
        print( "@ TestSolcOptimize: start..." )
        print( "@-----------------------------" )

        do{
            // 接続先の設定
            self.setTarget()
            
            // キーストア（イーサリアムアドレス）の設定
            self.setKeystore()
            
            // 残高の確認
            self.checkBalance()

            // コンパイラの最適化別コントラクトの呼び出し
            try self.checkSolc5( opt:CompileOpt5.optType.runs_1 )
            try self.checkSolc5( opt:CompileOpt5.optType.runs_200 )
            try self.checkSolc5( opt:CompileOpt5.optType.runs_2000 )
            try self.checkSolc5( opt:CompileOpt5.optType.non )
            try self.checkSolc4( opt:CompileOpt4.optType.runs_1 )
            try self.checkSolc4( opt:CompileOpt4.optType.runs_200 )
            try self.checkSolc4( opt:CompileOpt4.optType.runs_2000 )
            try self.checkSolc4( opt:CompileOpt4.optType.non )
        } catch {
            print( "@ TestSolcOptimize: error:", error )
        }
        
        print( "@-----------------------------" )
        print( "@ TestSolcOptimize: finished" )
        print( "@-----------------------------" )
    }

    //-----------------------------------------
    // JSONファイルの保存
    //-----------------------------------------
    func saveKeystoreJson( json : String ) -> Bool{
        let userDir = NSSearchPathForDirectoriesInDomains( .documentDirectory, .userDomainMask, true )[0]
        let keyPath = userDir + "/" + self.keyFile
        return FileManager.default.createFile( atPath: keyPath, contents: json.data( using: .ascii ), attributes: nil )
    }
    
    //-----------------------------------------
    // JSONファイルの読み込み
    //-----------------------------------------
    func loadKeystoreJson() -> String?{
        let userDir = NSSearchPathForDirectoriesInDomains( .documentDirectory, .userDomainMask, true )[0]
        let keyPath = userDir + "/" + self.keyFile
        return try? String( contentsOfFile: keyPath, encoding: String.Encoding.ascii )
    }

    //-----------------------------------------
    // 接続先設定
    //-----------------------------------------
    func setTarget(){
        print( "@------------------" )
        print( "@ setTarget" )
        print( "@------------------" )
        _ = self.helper.setTarget( target: self.targetNet )
        
        let target = self.helper.getCurTarget()
        print( "@ target:", target! )
    }

    //-----------------------------------------
    // キーストア設定
    //-----------------------------------------
    func setKeystore() {
        print( "@------------------" )
        print( "@ setKeystore" )
        print( "@------------------" )

        // キーストアのファイルを読み込む
        if let json = self.loadKeystoreJson(){
            print( "@ loadKeystoreJson: json=", json )

            let result = helper.loadKeystore( json: json )
            print( "@ loadKeystore: result=", result )
        }
        
        // この時点でヘルパーが無効であれば新規キーストアの作成
        if !helper.isValid() {
            if helper.createNewKeystore(password: self.password){
                print( "@ CREATE NEW KEYSTORE" )
                
                let json = helper.getCurKeystoreJson()
                print( "@ Write down below json code to import generated account into your wallet apps(e.g. MetaMask)" )
                print( json! )

                let privateKey = helper.getCurPrivateKey( password : self.password )
                print( "@ privateKey:", privateKey! )

                // 出力
                let result = self.saveKeystoreJson( json: json! )
                print( "@ saveKeystoreJson: result=", result )
            }
        }

        // イーサリアムアドレスの確認
        let ethereumAddress = helper.getCurEthereumAddress()
        print( "@ CURRENT KEYSTORE" )
        print( "@ ethereumAddress:", ethereumAddress! )
    }

    //------------------------
    // 残高確認
    //------------------------
    func checkBalance() {
        print( "@------------------" )
        print( "@ checkBalance" )
        print( "@------------------" )
        
        let balance = self.helper.getCurBalance()
        print( "@ balance:", balance!, "wei" )
    }
    
    //--------------------------
    // solc 0.5.12
    //--------------------------
    func checkSolc5( opt:CompileOpt5.optType ) throws{
        print( "@-----------------------------------" )
        print( "@ solc: 0.5.12, optmize: \(opt)" )
        print( "@-----------------------------------" )

        let contract = CompileOpt5()

        // 要素数取得
        let total = try contract.getTotalKitties( self.helper, opt )
        print( "@ total kitties:", total! )

        // create with memory
        let hash = try contract.createKitty( self.helper, opt, password:self.password, val256:( total! ) )
        print( "@ createKitty:", hash )
    }
    
    //--------------------------
    // solc 0.4.25
    //--------------------------
    func checkSolc4( opt:CompileOpt4.optType ) throws{
        print( "@-----------------------------------" )
        print( "@ solc: 0.4.25, optmize: \(opt)" )
        print( "@-----------------------------------" )

        let contract = CompileOpt4()

        // 要素数取得
        let total = try contract.getTotalKitties( self.helper, opt )
        print( "@ total kitties:", total! )

        // create with memory
        let hash = try contract.createKitty( self.helper, opt, password:self.password, val256:( total! ) )
        print( "@ createKitty:", hash )
    }
}
