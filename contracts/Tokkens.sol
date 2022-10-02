//SPDX-License-Indentifier: MIT
pragma solidity ^0.8.4;

// Interfaz
interface IERC20{
    function totalSupply() external view returns(uint256);
    function balanceOf(address account) external view returns(uint256);
    function transfer(address to, uint256 amount) external returns(bool); 
    function allowance(address owner, address spender) external view returns(uint256);
    function approve(address spender, uint256 amount) external returns(bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns(bool);
    
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 amount
    );

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 amount
    );
}

contract ERC20 is IERC20{

   mapping(address => uint256) private _balances;
   mapping(address => mapping(address => uint256)) private _allowances;

   string private  _name;
   string private  _symbol;
   uint256 private _totalSupply;

   constructor(string memory name_, string memory symbol_){
       _name = name_;
       _symbol = symbol_;
   }

   function name() public view virtual returns(string memory){
       return _name;
   }

    function symbol() public view virtual returns(string memory){
       return _symbol;
   }

   function decimals() public view virtual returns(uint8){
       return 18;
   } 

   function totalSupply() public view virtual override returns(uint256){
       return _totalSupply;
   }

   function balanceOf(address account) public view virtual override returns(uint256){
       return _balances[account];
   }

   //transfer function
   function transfer(address to, uint256 amount) public virtual override returns(bool){
       address owner = msg.sender;
       _transfer(owner, to, amount); //Internal function
       return true;
   }

   //allowance function
   function allowance(address owner, address spender) public view virtual override returns(uint256){
      return  _allowances[owner][spender];
   }

   //assigment tokken whit approve function
   function approve(address spender, uint256 amount) public virtual override returns(bool){
        address owner = msg.sender;
        _approve(owner, spender, amount);  //Internal function
       return true;
   }

   //TransferFrom function
   function transferFrom(
       address from,
       address to,
       uint256 amount
   ) public virtual override returns(bool){
       address spender = msg.sender;
       _spenderAllowance(from, spender, amount);
       _transfer(from, to, amount);
       return true;
   }

   //funcion to increase allowance
   function increaseAllowance(
       address spender,
       uint256 addedValue
   ) public virtual returns(bool){
       address owner = msg.sender;
       _approve(owner, spender, _allowances[owner][spender] + addedValue);
       return true;
    }

    //function to decrement allowance
    function decreaseAllowance(
        address spender,
        uint256 subtractedValue
    ) public virtual returns(bool){
        address owner = msg.sender;
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue,"ERC20: decreased allowance below zero");
        //funcion interna de solidity que sirve para ver al gas a gastar
        unchecked{
              _approve(owner, spender, currentAllowance - subtractedValue);
        }
        return true;
    }

    // terminando las funciones _transfer, _allowance, _approve
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual{
        require(from != address(0),"ERC20: transfer from the zero address");
        require(to != address(0),"ERC20: transfer to the zero address");
        _beforeTokenTransfer(from, to, amount);
        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount,"ERC20: transfer amount exceeds balance");
        unchecked{
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;
        emit Transfer(from, to, amount);
        _afterTokenTransfer(from, to, amount);
    }

    //function mint
    function _mint(address account, uint amount) internal virtual {
        require(account != address(0),"ERC20: mint to the zero address");
        _beforeTokenTransfer(address(0),account,amount);
        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0),account,amount);
        _afterTokenTransfer(address(0), account, amount);
    }

    //funcion para quemar tokkens
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0),"ERC20: burn from the zero address");
        _afterTokenTransfer(account, address(0),amount);
        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount,"ERC20: burn amount exceeds balance");
        unchecked{
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;
        emit Transfer(account, address(0), amount);
        _afterTokenTransfer(account, address(0), amount);
        
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    )internal virtual {
        require(owner != address(0),"ERC20: approve from zero address");
        require(spender != address(0),"ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spenderAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount,"ERC20: insufficient allowence");
            unchecked{
                _approve(owner, spender, amount);
            }
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual{}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual{}


}