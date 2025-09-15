// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title Lista de Tareas en Solidity con búsqueda por hash y nombre
contract ListaDeTareas {

    /// @dev Enum de estados posibles para la tarea
    enum EstadoTarea { Pendiente, EnProceso, Completada }

    /// @dev Estructura para representar una tarea
    struct Tarea {
        string Nombre_De_Tarea;
        string Descripcion_De_Tarea;
        EstadoTarea estado;
        uint fecha_creacion;
        bytes32 hash_tarea;
        address creador;
    }

    // Lista de tareas
    Tarea[] public tareas;

    // Mapeos para búsquedas
    mapping(bytes32 => uint) public indicePorHashTarea;
    mapping(string => uint[]) public indicesPorNombre;

    // Evento cuando se crea una tarea
    event TareaCreada(
        string Nombre_De_Tarea,
        string Descripcion_De_Tarea,
        EstadoTarea estado,
        uint fecha,
        bytes32 hash_tarea,
        address creador
    );

    // Evento cuando se edita una tarea
    event EstadoActualizado(
        string Nombre_De_Tarea,
        EstadoTarea nuevo_estado,
        bytes32 nuevo_hash_tarea
    );

    /// @notice Crea una nueva tarea
    function crearTarea(string calldata _Nombre_De_Tarea, string calldata _Descripcion_De_Tarea) external {
        uint _fecha = block.timestamp;
        EstadoTarea estadoInicial = EstadoTarea.Pendiente;

        bytes32 _hash_tarea = generarHashTarea(_Nombre_De_Tarea, _fecha, estadoInicial);

        Tarea memory nueva = Tarea({
            Nombre_De_Tarea: _Nombre_De_Tarea,
            Descripcion_De_Tarea: _Descripcion_De_Tarea,
            estado: estadoInicial,
            fecha_creacion: _fecha,
            hash_tarea: _hash_tarea,
            creador: msg.sender
        });

        tareas.push(nueva);
        uint indice = tareas.length - 1;

        indicePorHashTarea[_hash_tarea] = indice;
        indicesPorNombre[_Nombre_De_Tarea].push(indice);

        emit TareaCreada(_Nombre_De_Tarea, _Descripcion_De_Tarea, estadoInicial, _fecha, _hash_tarea, msg.sender);
    }

    /// @notice Cambia el estado de una tarea y actualiza su hash
    function actualizarEstado(uint indice, EstadoTarea nuevoEstado) external {
        require(indice < tareas.length, "Indice invalido");
        Tarea storage tarea = tareas[indice];
        require(msg.sender == tarea.creador, "Solo el creador puede editar la tarea");

        tarea.estado = nuevoEstado;
        tarea.hash_tarea = generarHashTarea(tarea.Nombre_De_Tarea, tarea.fecha_creacion, nuevoEstado);

        // Actualizar el mapping con el nuevo hash
        indicePorHashTarea[tarea.hash_tarea] = indice;

        emit EstadoActualizado(tarea.Nombre_De_Tarea, nuevoEstado, tarea.hash_tarea);
    }

    /// @notice Devuelve la cantidad total de tareas
    function obtenerCantidadTareas() external view returns (uint) {
        return tareas.length;
    }

    /// @notice Devuelve una tarea por índice
    function obtenerTareaPorIndice(uint indice) external view returns (
        string memory Nombre_De_Tarea,
        string memory Descripcion_De_Tarea,
        EstadoTarea estado,
        uint fecha,
        bytes32 hash_tarea,
        address creador
    ) {
        require(indice < tareas.length, "Indice invaido");
        Tarea memory t = tareas[indice];
        return (t.Nombre_De_Tarea, t.Descripcion_De_Tarea, t.estado, t.fecha_creacion, t.hash_tarea, t.creador);
    }

    /// @notice Busca tarea por hash_tarea
    /// @notice Devuelve una firma por su hash_firma
    /// @notice En la siguiente variable se guarda el hash "bytes32 _hash_tarea"
    /// @notice Ejemplo 0xbe2b67652a8d3d321bdf67f673fd3705e8ddf81d16ed8781e69c034491d50448

    function buscarTareaPorHash(bytes32 _hash_tarea) external view returns (
        string memory Nombre_De_Tarea,
        string memory Descripcion_De_Tarea,
        EstadoTarea estado,
        uint fecha,
        address creador
    ) {
        uint indice = indicePorHashTarea[_hash_tarea];
        require(indice < tareas.length, "No se encontro la tarea");

        Tarea memory t = tareas[indice];
        return (t.Nombre_De_Tarea, t.Descripcion_De_Tarea, t.estado, t.fecha_creacion, t.creador);
    }

    /// @notice Busca todas las tareas con un nombre específico
    /// @notice En la siguiente variable se guarda el hash "string _Nombre_De_Tarea"
    /// @notice Ejemplo "tarea 1"
    function buscarTareasPorNombre(string calldata _Nombre_De_Tarea) external view returns (Tarea[] memory resultados) {
        uint[] memory indices = indicesPorNombre[_Nombre_De_Tarea];
        resultados = new Tarea[](indices.length);

        for (uint i = 0; i < indices.length; i++) {
            resultados[i] = tareas[indices[i]];
        }
    }

    /// @notice Genera un hash único de la tarea con nombre, fecha y estado
    function generarHashTarea(string memory _Nombre_De_Tarea, uint _fecha, EstadoTarea _estado) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_Nombre_De_Tarea, _fecha, _estado));
    }
}



