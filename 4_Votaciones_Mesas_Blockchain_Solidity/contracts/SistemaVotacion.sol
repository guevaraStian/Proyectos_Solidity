// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title Sistema de almacenamiento de votaciones
contract SistemaVotacion {

    /// @dev Estructura de una planilla de votacion
    struct PlanillaVotacion {
        string ciudad;
        uint numero_mesa;
        string nombre_votante_1;
        uint cantidad_1;
        string nombre_votante_2;
        uint cantidad_2;
        uint votos_blanco;
        uint votos_totales;
        uint fecha_creacion_planilla;
        bytes32 hash_planilla;
        address creador;
    }

    // Lista de planillas
    PlanillaVotacion[] public planillas;

    // Mapeo para buscar por hash
    mapping(bytes32 => uint) public indicePorHash;

    // Evento al registrar una planilla
    event PlanillaRegistrada(
        bytes32 hash_planilla,
        string ciudad,
        uint numero_mesa,
        uint fecha_creacion_planilla,
        address creador
    );

    /// @notice Registrar una nueva planilla
    function registrarPlanilla(
        string calldata _ciudad,
        uint _numero_mesa,
        string calldata _nombre_votante_1,
        uint _cantidad_1,
        string calldata _nombre_votante_2,
        uint _cantidad_2,
        uint _votos_blanco
    ) external {
        uint _fecha = block.timestamp;
        uint _votos_totales = _cantidad_1 + _cantidad_2 + _votos_blanco;

        bytes32 _hash = keccak256(
            abi.encodePacked(
                _ciudad,
                _numero_mesa,
                _nombre_votante_1,
                _cantidad_1,
                _nombre_votante_2,
                _cantidad_2,
                _votos_blanco,
                _votos_totales,
                _fecha
            )
        );

        PlanillaVotacion memory nueva = PlanillaVotacion({
            ciudad: _ciudad,
            numero_mesa: _numero_mesa,
            nombre_votante_1: _nombre_votante_1,
            cantidad_1: _cantidad_1,
            nombre_votante_2: _nombre_votante_2,
            cantidad_2: _cantidad_2,
            votos_blanco: _votos_blanco,
            votos_totales: _votos_totales,
            fecha_creacion_planilla: _fecha,
            hash_planilla: _hash,
            creador: msg.sender
        });

        planillas.push(nueva);
        indicePorHash[_hash] = planillas.length - 1;

        emit PlanillaRegistrada(_hash, _ciudad, _numero_mesa, _fecha, msg.sender);
    }

    /// @notice Obtener la cantidad total de planillas
    function obtenerCantidadPlanillas() external view returns (uint) {
        return planillas.length;
    }

    /// @notice Obtener una planilla por su indice
    function obtenerPlanillaPorIndice(uint indice) external view returns (
        string memory ciudad,
        uint numero_mesa,
        string memory nombre_votante_1,
        uint cantidad_1,
        string memory nombre_votante_2,
        uint cantidad_2,
        uint votos_blanco,
        uint votos_totales,
        uint fecha_creacion_planilla,
        bytes32 hash_planilla,
        address creador
    ) {
        require(indice < planillas.length, "Indice fuera de rango");
        PlanillaVotacion memory p = planillas[indice];
        return (
            p.ciudad,
            p.numero_mesa,
            p.nombre_votante_1,
            p.cantidad_1,
            p.nombre_votante_2,
            p.cantidad_2,
            p.votos_blanco,
            p.votos_totales,
            p.fecha_creacion_planilla,
            p.hash_planilla,
            p.creador
        );
    }

    /// @notice Buscar planilla por su hash
    function buscarPlanillaPorHash(bytes32 _hash) external view returns (
        string memory ciudad,
        uint numero_mesa,
        string memory nombre_votante_1,
        uint cantidad_1,
        string memory nombre_votante_2,
        uint cantidad_2,
        uint votos_blanco,
        uint votos_totales,
        uint fecha_creacion_planilla,
        address creador
    ) {
        uint indice = indicePorHash[_hash];
        require(indice < planillas.length, "Planilla no encontrada");

        PlanillaVotacion memory p = planillas[indice];
        return (
            p.ciudad,
            p.numero_mesa,
            p.nombre_votante_1,
            p.cantidad_1,
            p.nombre_votante_2,
            p.cantidad_2,
            p.votos_blanco,
            p.votos_totales,
            p.fecha_creacion_planilla,
            p.creador
        );
    }

    /// @notice Generar hash para verificacion externa
    function generarHashPlanilla(
        string memory _ciudad,
        uint _numero_mesa,
        string memory _nombre_votante_1,
        uint _cantidad_1,
        string memory _nombre_votante_2,
        uint _cantidad_2,
        uint _votos_blanco,
        uint _fecha
    ) public pure returns (bytes32) {
        uint _votos_totales = _cantidad_1 + _cantidad_2 + _votos_blanco;

        return keccak256(
            abi.encodePacked(
                _ciudad,
                _numero_mesa,
                _nombre_votante_1,
                _cantidad_1,
                _nombre_votante_2,
                _cantidad_2,
                _votos_blanco,
                _votos_totales,
                _fecha
            )
        );
    }
}