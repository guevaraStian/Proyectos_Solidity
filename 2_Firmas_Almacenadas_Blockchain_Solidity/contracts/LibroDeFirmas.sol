// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title Libro de Firmas con búsqueda por texto, fecha y hash
contract LibroDeFirmas {

    /// @dev Representa una firma en el libro
    struct Firma {
        address firmante;         // Dirección de quien firma
        string Texto_firma;       // Texto del mensaje
        uint fecha;               // Timestamp
        bytes32 hash_firma;       // Hash generado desde texto + fecha
    }

    // Lista de firmas registradas
    Firma[] public firmas;

    // Mapeos para búsqueda
    mapping(bytes32 => uint) public indicePorHashLibro;
    mapping(string => uint[]) public indicesPorTextoFirma;

    // Evento emitido al crear una firma
    event NuevaFirma(
        address indexed firmante,
        string Texto_firma,
        uint fecha,
        bytes32 hash_firma
    );

    /// @notice Permite a un usuario firmar el libro
    /// @param _Texto_firma El texto del mensaje a firmar
    function firmar(string calldata _Texto_firma) external {
        uint _fecha = block.timestamp;

        // Generar el hash del texto + fecha
        bytes32 _hash_firma = keccak256(abi.encodePacked(_Texto_firma, _fecha));

        Firma memory nueva = Firma({
            firmante: msg.sender,
            Texto_firma: _Texto_firma,
            fecha: _fecha,
            hash_firma: _hash_firma
        });

        firmas.push(nueva);

        uint indice = firmas.length - 1;

        // Guardar índice para búsquedas
        indicePorHashLibro[_hash_firma] = indice;
        indicesPorTextoFirma[_Texto_firma].push(indice);

        emit NuevaFirma(msg.sender, _Texto_firma, _fecha, _hash_firma);
    }

    /// @notice Devuelve la cantidad total de firmas registradas
    function obtenerCantidadFirmas() external view returns (uint) {
        return firmas.length;
    }

    /// @notice Devuelve una firma específica por índice
    /// @notice Empieza en 0
    function obtenerFirmaPorIndice(uint indice) external view returns (
        address firmante,
        string memory Texto_firma,
        uint fecha,
        bytes32 hash_firma
    ) {
        require(indice < firmas.length, "Indice fuera de rango");
        Firma memory f = firmas[indice];
        return (f.firmante, f.Texto_firma, f.fecha, f.hash_firma);
    }

    /// @notice Devuelve una firma por su hash_firma
    /// @notice En la siguiente variable se guarda el hash "bytes32 _hash_firma"
    /// @notice Ejemplo 0xbe2b67652a8d3d321bdf67f673fd3705e8ddf81d16ed8781e69c034491d50448

    function buscarFirmaPorHash(bytes32 _hash_firma) external view returns (
        address firmante,
        string memory Texto_firma,
        uint fecha,
        bytes32 hash
    ) {
        uint indice = indicePorHashLibro[_hash_firma];
        require(indice < firmas.length, "No se encontro la firma");

        Firma memory f = firmas[indice];
        return (f.firmante, f.Texto_firma, f.fecha, f.hash_firma);
    }

    /// @notice Devuelve todas las firmas que tengan un texto específico
    /// @param _Texto_firma Texto exacto a buscar
    /// @notice En la siguiente variable se guarda el hash "string _Texto_firma"
    /// @notice Ejemplo 1234567
    function buscarFirmasPorTexto(string calldata _Texto_firma) external view returns (
        Firma[] memory resultados
    ) {
        uint[] memory indices = indicesPorTextoFirma[_Texto_firma];
        resultados = new Firma[](indices.length);

        for (uint i = 0; i < indices.length; i++) {
            resultados[i] = firmas[indices[i]];
        }
    }

    /// @notice Genera el hash_firma fuera del contrato (útil para buscar)
    /// @param _Texto_firma El texto exacto usado
    /// @param _fecha El timestamp usado en la firma original
    function generarHashLibro(string memory _Texto_firma, uint _fecha) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_Texto_firma, _fecha));
    }
}