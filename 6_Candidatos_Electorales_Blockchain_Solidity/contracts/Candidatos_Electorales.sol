// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RegistroCandidatos {

    // Estructura del candidato
    struct Candidato {
        string cedula;
        string nombre;
        string partido;
        uint edad;
        string propuesta;
        bool existe;
    }

    // Se mapean los candidatos
    mapping(string => Candidato) private candidatos;

    // Se crea la variable lista de cedulas
    string[] private listaCedulas;

    // Se crea la variable administrador
    address public administrador;

    // Mensaje que sale cuando un usuario NO ADMINISTRADOR intenta borrar
    modifier soloAdministrador() {
        require(msg.sender == administrador, "Solo el administrador puede ejecutar esta funcion");
        _;
    }

    // Constructor: define al administrador
    constructor() {
        administrador = msg.sender;
    }

    // Funcion que crea el candidato ingresandole los datos
    function crearCandidato(string memory cedula, string memory nombre, string memory partido, uint edad, string memory propuesta) public soloAdministrador {
        require(!candidatos[cedula].existe, "El candidato ya existe con esta cedula");
        
        candidatos[cedula] = Candidato({
            cedula: cedula,
            nombre: nombre,
            partido: partido,
            edad: edad,
            propuesta: propuesta,
            existe: true
        });

        listaCedulas.push(cedula);
    }

    // Funcion pa buscar datos de un candidato por medio de la cedula
    function verCandidato(string memory cedula) public view returns (string memory nombre, string memory partido, uint edad, string memory propuesta) {
        require(candidatos[cedula].existe, "Candidato no encontrado");
        Candidato memory c = candidatos[cedula];
        return (c.nombre, c.partido, c.edad, c.propuesta);
    }

    // Funcion que deja editar candidato luego de buscarlo con la cedula
    function editarCandidato(string memory cedula, string memory nombre, string memory partido, uint edad, string memory propuesta) public soloAdministrador {
        require(candidatos[cedula].existe, "Candidato no encontrado");
        
        candidatos[cedula].nombre = nombre;
        candidatos[cedula].partido = partido;
        candidatos[cedula].edad = edad;
        candidatos[cedula].propuesta = propuesta;
    }

    // Funcion para borrar candidato si eres administrador
    function eliminarCandidato(string memory cedula) public soloAdministrador {
        require(candidatos[cedula].existe, "Candidato no encontrado");
        
        delete candidatos[cedula];

        // Opcional: eliminar la cédula de la lista
        for (uint i = 0; i < listaCedulas.length; i++) {
            if (keccak256(bytes(listaCedulas[i])) == keccak256(bytes(cedula))) {
                listaCedulas[i] = listaCedulas[listaCedulas.length - 1];
                listaCedulas.pop();
                break;
            }
        }
    }

    // Verificar si un candidato existe
    function candidatoExiste(string memory cedula) public view returns (bool) {
        return candidatos[cedula].existe;
    }

    // Obtener total de candidatos registrados
    function totalCandidatos() public view returns (uint) {
        return listaCedulas.length;
    }

    // Obtener todas las cédulas registradas (por si quieres listar todos)
    function obtenerTodasLasCedulas() public view returns (string[] memory) {
        return listaCedulas;
    }
}