// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function approve(address spender, uint256 amount) external returns (bool);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);
}

interface IContractStakeBary {
    function deposit(uint256 pid, uint256 amount) external;

    function withdrawAndHarvest(uint256 pid, uint256 amount) external;

    function harvest(uint256 pid) external;

    function pendingReward(uint256 _pid, address _user)
        external
        view
        returns (uint256 pending);
}

interface IContractStakeDefusion {
    function stake() external payable;

    function unstake(uint256 _amount) external;

    function withdrawReward() external;

    function withdrawUnstakedAmount(uint256 _blockNumber) external;

    function getWithdrawBlockNumbers(address _staker)
        external
        view
        returns (uint256[] memory);

      function currentStakerReward(address _staker)
        external
        view
        returns (uint256);
}

contract StakeMaster {
    // struct pendingData {
    //     uint256 
    // }

    mapping(address => uint256) public balances;
    mapping(address => uint256) public pendingUnstake;
    mapping(address => uint256[]) public pendingUnstakeBlock;
    mapping(address => uint256) public rewards;
    uint256 public totalBalance;

    address addressSvic = 0xCdde1f5D971A369eB952192F9a5C367f33a0A891;
    address contractBary = 0x0AFdBE5989CAB06E66244CC2583F0caeECb6EA8e;
    address contractDefution = 0x6D2B2e6ff4D7614994a4314D492207b6342b1029;


    function deposit() public payable {
        require(msg.value > 10, "vic > 10");
        IContractStakeDefusion(contractDefution).stake{value: msg.value}();

        uint256 allowance = IERC20(addressSvic).allowance(address(this), contractBary);
        if(allowance == 0){
            IERC20(addressSvic).approve(
                        contractBary,
                        100000000000101010010010100100100101001
                    );
        }

     

        uint256 receivedTokens = IERC20(addressSvic).balanceOf(address(this));
        IContractStakeBary(contractBary).deposit(0, receivedTokens);
        balances[msg.sender] += msg.value;
    }

    function withdraw() public {
        uint256 total = balances[address(this)] + rewards[msg.sender];
        IContractStakeBary(contractBary).withdrawAndHarvest(
            0,
            total
        );
        IContractStakeDefusion(contractDefution).unstake(total);

        uint256[] memory blockNumbers = IContractStakeDefusion(
            contractDefution
        ).getWithdrawBlockNumbers(address(this));

        pendingUnstake[msg.sender] += balances[msg.sender];
        balances[msg.sender] = 0;
        pendingUnstakeBlock[msg.sender].push(blockNumbers[blockNumbers.length - 1]);
        rewards[msg.sender] = 0;
    }

    function withdrawPending(uint256 blockNumber) public {
        IContractStakeDefusion(contractDefution).withdrawUnstakedAmount(
            blockNumber
        );
        pendingUnstake[msg.sender] = 0;
    }

    function reStake(address[] memory listAddress) public {
        IContractStakeBary contractBaryon = IContractStakeBary(contractBary);
        IContractStakeDefusion contractDefusion = IContractStakeDefusion(contractDefution);

        uint256 rewardBaryon = contractBaryon.pendingReward(
            0,
            address(this)
        );
        uint256 rewardDefusion = contractDefusion.currentStakerReward(address(this));

        uint256 total = rewardBaryon + rewardDefusion;

        if (total > 10) {
            contractDefusion.stake{value: total}();
            contractBaryon.deposit(0, total);
        }
        for (uint256 i = 0; i < listAddress.length; i++) {
            rewards[listAddress[i]] += total / totalBalance * balances[listAddress[i]];
        }
    }

   function getBlockNumber(address wallet) public view returns (uint256[] memory) {
        return pendingUnstakeBlock[wallet];
    }

    function harvestBary() public {
        IContractStakeBary(contractBary).harvest(0);
    }

    function harvestDefu() public {
        IContractStakeDefusion(contractDefution).withdrawReward();
    }

    //

    function unstakeBary(uint256 _amount) public {
        IContractStakeBary(contractBary).withdrawAndHarvest(
            0,
            _amount
        );
    }

    function unstakeDefu(uint256 _amount) public {
        IContractStakeDefusion(contractDefution).unstake(_amount);
    }

    function withdrawRewardDefu() public {
        IContractStakeDefusion(contractDefution).withdrawReward();
    }

    function withdrawUnstakedAmountDefu(
        uint256 _blockNumber
    ) public {
        IContractStakeDefusion(contractDefution).withdrawUnstakedAmount(
            _blockNumber
        );
    }

    function getWithdrawBlockNumbersDefu(address _staker)
        public
        view
    {
        IContractStakeDefusion(contractDefution).getWithdrawBlockNumbers(
            _staker
        );
    }
}
