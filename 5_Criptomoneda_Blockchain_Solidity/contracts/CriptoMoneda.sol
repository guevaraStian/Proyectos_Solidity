// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title Criptomoneda Sebas Español
 * @dev Contrato tipo ERC-20 con funcionalidades completas y variables en español.
 */
contract Criptomoneda {
    // Variables que tiene cada criptomoneda
    string public nombre = "MiCriptoSebas";
    string public simbolo = "MCS";
    uint8 public decimales = 18;
    uint256 public suministroTotal;
    mapping(address => uint256) public saldo;
    mapping(address => mapping(address => uint256)) public aprobaciones;
    address public propietario;
    address public minter;

    // Eventos que se pueden hacer con la criptomoneda
    event Transferencia(address indexed desde, address indexed hacia, uint256 valor);
    event Aprobacion(address indexed propietario, address indexed autorizado, uint256 valor);
    event TokensQuemados(address indexed cuenta, uint256 cantidad);
    event TokensMinteados(address indexed cuenta, uint256 cantidad);
    event PropietarioTransferido(address indexed anterior, address indexed nuevo);
    event MinterCambiado(address indexed anterior, address indexed nuevo);

    // Modificaciones de cuando NO se vende una moneda a otro propietario
    modifier soloPropietario() {
        require(msg.sender == propietario, "Solo el propietario puede ejecutar esto");
        _;
    }

    modifier soloMinter() {
        require(msg.sender == minter, "Solo el minter puede ejecutar esto");
        _;
    }

    // Constructor de la modificacion
    constructor(uint256 _suministroInicial) {
        propietario = msg.sender;
        minter = msg.sender;
        _mintear(propietario, _suministroInicial);
    }

    // Funcion que solicita tranferir moneda
    function transferir(address _destinatario, uint256 _cantidad) public returns (bool) {
        require(saldo[msg.sender] >= _cantidad, "Saldo insuficiente");
        _transferir(msg.sender, _destinatario, _cantidad);
        return true;
    }

    // Funcion que aprueba la tranferencia de la moneda
    function aprobar(address _autorizado, uint256 _cantidad) public returns (bool) {
        aprobaciones[msg.sender][_autorizado] = _cantidad;
        emit Aprobacion(msg.sender, _autorizado, _cantidad);
        return true;
    }

    // Transferir luego de que ya este aprobado
    function transferirDesde(address _origen, address _destino, uint256 _cantidad) public returns (bool) {
        require(saldo[_origen] >= _cantidad, "Saldo insuficiente");
        require(aprobaciones[_origen][msg.sender] >= _cantidad, "No autorizado");
        aprobaciones[_origen][msg.sender] -= _cantidad;
        _transferir(_origen, _destino, _cantidad);
        return true;
    }

    // Quemar un token propio
    function quemar(uint256 _cantidad) public returns (bool) {
        require(saldo[msg.sender] >= _cantidad, "Saldo insuficiente para quemar");
        saldo[msg.sender] -= _cantidad;
        suministroTotal -= _cantidad;
        emit TokensQuemados(msg.sender, _cantidad);
        emit Transferencia(msg.sender, address(0), _cantidad);
        return true;
    }

    // Mintear tokens (solo minter) pasar token a una moneda
    function mintear(address _cuenta, uint256 _cantidad) public soloMinter returns (bool) {
        _mintear(_cuenta, _cantidad);
        return true;
    }

    // Modificar el mintear
    function cambiarMinter(address _nuevoMinter) public soloPropietario {
        require(_nuevoMinter != address(0), "Direccion no valida");
        emit MinterCambiado(minter, _nuevoMinter);
        minter = _nuevoMinter;
    }

    // Transferor la variable de propietario a otra persona
    function transferirPropiedad(address _nuevoPropietario) public soloPropietario {
        require(_nuevoPropietario != address(0), "Direccion no valida");
        emit PropietarioTransferido(propietario, _nuevoPropietario);
        propietario = _nuevoPropietario;
    }

    // Funciones internas

    function _transferir(address _desde, address _hacia, uint256 _cantidad) internal {
        require(_hacia != address(0), "Direccion destino no valida");
        saldo[_desde] -= _cantidad;
        saldo[_hacia] += _cantidad;
        emit Transferencia(_desde, _hacia, _cantidad);
    }

    function _mintear(address _cuenta, uint256 _cantidad) internal {
        require(_cuenta != address(0), "Direccion no valida");
        saldo[_cuenta] += _cantidad;
        suministroTotal += _cantidad;
        emit TokensMinteados(_cuenta, _cantidad);
        emit Transferencia(address(0), _cuenta, _cantidad);
    }
}