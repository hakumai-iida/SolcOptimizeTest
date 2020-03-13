//
//  CompileOpt4.swift
//  SolcOptimizeTest
//
//  Created by 飯田白米 on 2020/03/12.
//  Copyright © 2020 飯田白米. All rights reserved.
//

import Foundation
import UIKit
import BigInt
import web3swift

//-----------------------------------------------------
// [CompileOpt4.sol]
//-----------------------------------------------------
class CompileOpt4 {
    //--------------------------------
    // [abi]ファイルの内容
    //--------------------------------
    internal let abiString = """
[
  {
    "constant": true,
    "inputs": [],
    "name": "getTotalKitties",
    "outputs": [
      {
        "name": "",
        "type": "uint256"
      }
    ],
    "payable": false,
    "stateMutability": "view",
    "type": "function"
  },
  {
    "constant": false,
    "inputs": [
      {
        "name": "_val256",
        "type": "uint256"
      }
    ],
    "name": "createKitty",
    "outputs": [],
    "payable": false,
    "stateMutability": "nonpayable",
    "type": "function"
  }
]
"""
    
    // 最適化タイプ
    public enum optType {
        case runs_1
        case runs_200
        case runs_2000
        case non
    }

    //--------------------------------
    // コントラクトの取得
    //--------------------------------
    internal func getContract( _ helper:Web3Helper, _ opt:optType ) -> web3.web3contract? {
        var address:String
        
        // FIXME ご自身がデプロイしたコントラクトのアドレスに置き換えてください
        // メモ：[rinkeby]のアドレスは実際に存在するコントラクトなので、そのままでも利用できます
        switch helper.getCurTarget()! {
        case Web3Helper.target.mainnet:
            address = ""
            
        case Web3Helper.target.ropsten:
            address = ""

        case Web3Helper.target.kovan:
            address = ""

        case Web3Helper.target.rinkeby:
            switch opt{
            case optType.runs_1:    address = "0x0Ef0F32a5b578fB55ed5b473A7692C4C79245d9A"
            case optType.runs_200:  address = "0xe64ed34bec878221a2f6b8438d19b6b9cb4e7946"
            case optType.runs_2000: address = "0x20823a466ccd51cfcb3711cfa805b8f414cdda4a"
            case optType.non:       address = "0xc80287f93662358774a32ba5318155e681cb204e"
            }
        }
        
        let contractAddress = EthereumAddress( address )
        
        let web3 = helper.getWeb3()
        
        let contract = web3!.contract( abiString, at: contractAddress, abiVersion: 2 )
        
        return contract
    }
    
    //---------------------------------------------------
    // getTotalKitties
    //---------------------------------------------------
    public func getTotalKitties( _ helper:Web3Helper, _ opt:optType ) throws -> BigUInt?{
        let contract = getContract( helper, opt )

        let tx = contract!.read( "getTotalKitties" )
        let response = try tx!.callPromise().wait()
        
        return response["0"] as? BigUInt
    }
    
    //---------------------------------------------------
    // createKitty
    //---------------------------------------------------
    public func createKitty( _ helper:Web3Helper, _ opt:optType, password:String, val256:BigUInt ) throws -> String{
        let contract = getContract( helper, opt )
        
        let parameters = [val256] as [AnyObject]
        let data = Data()
        var options = TransactionOptions.defaultOptions
        options.from = helper.getCurAddress()
        let tx = contract!.write( "createKitty", parameters:parameters, extraData:data, transactionOptions:options )
        let response = try tx!.sendPromise( password: password ).wait()
        
        return response.hash
    }
}
