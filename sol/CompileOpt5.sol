pragma solidity 0.5.12;

contract CompileOpt5{
  // クリプトキティの構造体を拝借
  struct Kitty {
    uint256 genes;
    uint64 birthTime;
    uint64 cooldownEndBlock;
    uint32 matronId;
    uint32 sireId;
    uint32 siringWithId;
    uint16 cooldownIndex;
    uint16 generation;
  }

  // ニャンコの配列
  Kitty[] internal kitties;

  // 要素数の取得
  function getTotalKitties() public view returns( uint256 ){
    return kitties.length;
  }

  // ニャンコの追加
  function createKitty( uint256 _val256 ) public{
    Kitty memory _kitty = Kitty({
      genes: _val256,
      birthTime: uint64(_val256),
      cooldownEndBlock: uint64(_val256),
      matronId: uint32(_val256),
      sireId: uint32(_val256),
      siringWithId: uint32(_val256),
      cooldownIndex: uint16(_val256),
      generation: uint16(_val256)
    });

    kitties.push( _kitty );
  }
}
