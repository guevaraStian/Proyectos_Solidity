
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract StorageContract {
    uint public numeroEntero;
    bool public booleano;
    uint public numeroDecimalSimulado; // Por ejemplo: 12.34 se guarda como 1234 (2 decimales)
    bytes1 public caracter;
    string public texto;

    // Evento para mostrar los datos en pantalla
    event DatosGuardados(
        uint numeroEntero,
        bool booleano,
        uint numeroDecimalSimulado,
        bytes1 caracter,
        string texto
    );

    // Función para almacenar los datos
    function guardarDatos(
        uint _numeroEntero,
        bool _booleano,
        uint _numeroDecimalSimulado,
        bytes1 _caracter,
        string calldata _texto
    ) public {
        numeroEntero = _numeroEntero;
        booleano = _booleano;
        numeroDecimalSimulado = _numeroDecimalSimulado;
        caracter = _caracter;
        texto = _texto;

        emit DatosGuardados(
            _numeroEntero,
            _booleano,
            _numeroDecimalSimulado,
            _caracter,
            _texto
        );
    }

    // Función para obtener los datos (opcional si usas las variables públicas)
    function obtenerDatos()
        public
        view
        returns (
            uint,
            bool,
            uint,
            bytes1,
            string memory
        )
    {
        return (numeroEntero, booleano, numeroDecimalSimulado, caracter, texto);
    }
}