//Sources:
//https://github.com/dappuniversity/nft/blob/master/src/contracts/Color.sol
//https://coursetro.com/posts/code/102/Solidity-Mappings-&-Structs-Tutorial

pragma solidity ^0.6.0;

//Not sure if I have to change this
import "@openzeppelin-solidity/contracts/token/ERC721/ERC721Full.sol";

contract PLTMProposal is ERC721Full{

	struct ProposalData {
		string message;
		//false until 10k votes have been received
		bool deposit;
		uint depositVotes;
		uint yesVotes;
		uint noVotes;
		//Shows how many votes one account has used
		mapping(address => uint) votesSpent;
		//true until deactivated after a week of deposit being true
		bool active;
	}

	//PLTMToken stored here:
	PLTMToken public tokens;

	//Array of IDs;
	uint[] private IDs;
	//mapping of IDs to strings
	mapping(uint => proposalData) _proposals;


	//constructor defines name, symbol
	constructor() ERC721Full("PLTMProposal", "PLTM Proposal") public {
	}

	//Can be created by anyone
	//Create new proposal
	function mint(string memory _proposal, PLTMToken _PLTM) public {

		//add a new ID;
		uint _id = IDs.length;
		IDs.push(_id);

		//Creates the new token
		_mint(msg.sender, _id);

		//Defines proposal for said id
		var proposal = _proposals[_id];
		proposal.message = _proposal;
		proposal.deposit = false;
		proposal.depositVotes = 0;
		proposal.yesVotes = 0;
		proposal.noVotes = 0;
		proposal.active = true;
	}

	function addDepositVotes(uint _numVotes, uint _id) public returns (bool success) {
		//Grabs proposal of said ID
		var proposal = _proposals[_id];
		//Requires the the proposal is on deposit mode
		require(!proposal.deposit);
		//Requires that the user can spend enough votes.
		require(_numVotes <= tokens.balanceOfVote(msg.sender) - votesSpent);

		proposal.depositVotes += _numVotes;
		proposal.votesSpent[msg.sender] += _numVotes;

		//Add in the countdown start I guess
		if(proposal.depositVotes >= 10000) {
			deposit = true;
			proposal.yesVotes = proposal.depositVotes;
			proposal.depositVotes = 0;
		}

		return true;
	}

	function vote(uint _numVotes, uint _id, bool yes) public returns (bool success) {
		//Grabs proposal of said ID
		var proposal = _proposals[_id];
		//Requires proposal to be active
		require(proposal.active);
		//Requires that the user can spend enough votes.
		require(_numVotes <= tokens.balanceOfVote(msg.sender) - votesSpent);

		if(yes){
			proposal.yesVotes += _numVotes;
		} else {
			proposal.noVotes += _numVotes;
		}
		proposal.votesSpent[msg.sender] += _numVotes;

		return true;
	}
}
