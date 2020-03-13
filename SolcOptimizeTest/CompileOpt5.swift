//
//  CompileOpt5.swift
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
// [CompileOpt5.sol]
//-----------------------------------------------------
class CompileOpt5 {
    //--------------------------------
    // [abi]ファイルの内容
    //--------------------------------
    internal let abiString = """
[
  {
    "constant": true,
    "inputs": [
      {
        "internalType": "uint256",
        "name": "",
        "type": "uint256"
      }
    ],
    "name": "kitties",
    "outputs": [
      {
        "internalType": "uint256",
        "name": "genes",
        "type": "uint256"
      },
      {
        "internalType": "uint64",
        "name": "birthTime",
        "type": "uint64"
      },
      {
        "internalType": "uint64",
        "name": "cooldownEndBlock",
        "type": "uint64"
      },
      {
        "internalType": "uint32",
        "name": "matronId",
        "type": "uint32"
      },
      {
        "internalType": "uint32",
        "name": "sireId",
        "type": "uint32"
      },
      {
        "internalType": "uint32",
        "name": "siringWithId",
        "type": "uint32"
      },
      {
        "internalType": "uint16",
        "name": "cooldownIndex",
        "type": "uint16"
      },
      {
        "internalType": "uint16",
        "name": "generation",
        "type": "uint16"
      }
    ],
    "payable": false,
    "stateMutability": "view",
    "type": "function"
  },
  {
    "constant": true,
    "inputs": [],
    "name": "getTotalKitties",
    "outputs": [
      {
        "internalType": "uint256",
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
        "internalType": "uint256",
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
            case optType.runs_1:    address = "0x4D99C806EcBE89292A1beCB1164DCa0b1bfD1a1A"
            case optType.runs_200:  address = "0x89CE1da328faDBA21b9b19A6E6b9D1DeFf8fACD6"
            case optType.runs_2000: address = "0x08069F39C1dE9166E66Ff4d14bc67a6Fc44FA578"
            case optType.non:       address = "0x42a315eb978d7978767AB93ec8A835655Ff76c0c"
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
