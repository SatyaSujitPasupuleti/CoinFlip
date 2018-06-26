pragma solidity ^0.4.23;
contract CoinFlip{
    bytes32  p1choice;
    bytes32 p2choice;
    uint votesForHeads;
    uint votesForTails;
    
    address player1;
    address player2;
  
     bytes32[] public voteCommits;
    mapping(bytes32 => string) voteStatuses; // Either `Committed` or `Revealed`
     uint public commitPhaseEndTime;
     uint public numberOfVotesCast = 0;
     uint8[] public votesForCalc;
     event logString(string);
    event newVoteCommit(string, bytes32);
event voteWinner(string, string);
     
    constructor(uint _commitPhaseLengthSecs) public{
        require(_commitPhaseLengthSecs>20);
        commitPhaseEndTime=now+ _commitPhaseLengthSecs* 1 seconds;
    }
       function commitVote(bytes32 _voteCommit) public{
        require(now<=commitPhaseEndTime);
        
        // Check if this commit has been used before
        bytes memory bytesVoteCommit = bytes(voteStatuses[_voteCommit]);
        require (bytesVoteCommit.length == 0);
        
        // We are still in the committing period & the commit is new so add it
        voteCommits.push(_voteCommit);
        voteStatuses[_voteCommit] = "Committed";
        numberOfVotesCast ++;
        emit newVoteCommit("Vote committed with the following hash:", _voteCommit);
}
 function revealVote(string _vote, bytes32 _voteCommit) public {
        require(now>=commitPhaseEndTime);
        
        // FIRST: Verify the vote & commit is valid
        bytes memory bytesVoteStatus = bytes(voteStatuses[_voteCommit]);
        if (bytesVoteStatus.length == 0) {
            emit logString('A vote with this voteCommit was not cast');
        } else if (bytesVoteStatus[0] != 'C') {
            emit logString('This vote was already cast');
            return;
        }
        
        if (_voteCommit != keccak256(bytes(_vote))) {
            emit logString('Vote hash does not match vote commit');
            return;
        }
        
        // NEXT: Count the vote!
        bytes memory bytesVote = bytes(_vote);
        if (bytesVote[0] == 'H') {
            votesForHeads = votesForHeads + 1;
            votesForCalc.push(1);
            emit logString('Vote for Heads counted.');
        } else if (bytesVote[0] == 'T') {
            votesForTails = votesForTails + 1;
            votesForCalc.push(2);
            emit logString('Vote for Tails counted.');
            
        } else {
            emit logString('Vote could not be read! Votes must start with the ASCII character `1` or `2`');
        }
        voteStatuses[_voteCommit] = "Revealed";
}
 function getWinner () constant public returns(string)  {
        // Only get winner after all vote commits are in
        require(now>commitPhaseEndTime);
        // Make sure all the votes have been counted
        require (votesForHeads + votesForTails == voteCommits.length) ;
        require(votesForHeads+votesForTails==2);
        uint8 randomNumber = votesForCalc[0];
        randomNumber^=votesForCalc[1];
        if(randomNumber%2==0){
            emit logString("The coin flipped is heads");
           if(votesForCalc[0]==1){
                return("Player 1 wins: Coin flipped is heads");
            }
            if(votesForCalc[1]==1)
            {
                return("Player 2 wins: coin flipped is heads");
            }
            
        }
        else{
            emit logString("The coin flipped is tails");
               if(votesForCalc[0]==2){
                return("Player 1 wins:coin flipped is tails");
            }
            if(votesForCalc[1]==2)
            {
                return("Player 2 wins:coin flipped is tails");
            }
        }
        
    
        
        
       
}

}