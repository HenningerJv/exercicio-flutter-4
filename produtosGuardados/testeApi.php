<?php
// http://localhost/api/testeApi.php/cliente/list
// Obtém URL de execução da API 
// servidor da api-> http://localhost/api/testeApi.php
// get -> http://localhost/api/testeApi.php/cliente * atenção no header passar method = get
// get -> http://localhost/api/testeApi.php/cliente/1' * atenção no header passar method = get e no body indicar o id(1)
// post ->http://localhost/api/testeApi.php/cliente atenção no header passar method = post (além dos campos no body)
// delete ->http://localhost/api/testeApi.php/cliente atenção no header passar method = delete (além dos campos no body e do id )
// update ->http://localhost/api/testeApi.php/cliente/1 atenção no header passar method = put (além dos campos no body e do id )

$uri = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
$uri = explode('/', $uri);

// Array de resposta para o servidor 
$response = array();

// Criar atributos a partir da URL (apenas para debug)
if (isset($response['folder'])) $response['folder'] = $uri[1];
if (isset($response['api'])) $response['api'] = $uri[2];
if (isset($response['endPoint'])) $response['endPoint'] = $uri[3];
if (isset($response['action'])) $response['action'] = $uri[4];

// Obtém método solicitado
$response['method'] = $_SERVER['REQUEST_METHOD'];

// Conexão com o banco de dados
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "api";

// Cria a conexão
$conn = new mysqli($servername, $username, $password, $dbname);

// Verifica a conexão
if ($conn->connect_error) {
    die("Erro na conexão com o banco de dados: " . $conn->connect_error);
}

// Executa a operação baseada no método HTTP
switch ($_SERVER['REQUEST_METHOD']) {
    case 'PUT':
        // Obtém os dados enviados no corpo da requisição
        $data = json_decode(file_get_contents("php://input"), true);
        $nome = $data['nome']; // Assume que os dados são enviados em JSON
        $categoria = $data['categoria'];
            
        $id = $uri[4];// id indicado pela requisição PUT
            
        // Atualiza o cliente no banco de dados
        $sql = "UPDATE cliente SET nome='$nome', categoria='$categoria' WHERE idcli=$id";
        if ($conn->query($sql) === TRUE) {
            if ($conn->affected_rows > 0) {
                $response['message'] = "Cliente atualizado com sucesso!";
            } else {
                
				$response['message'] = "Nada foi alterado!";
            }
        } 
		else{
			$response['message'] = "Erro ao atualizar cliente: " . $conn->error;
		}			
        break;
    case 'POST':
        // Insere um novo cliente no banco de dados
        $data = json_decode(file_get_contents("php://input"), true);
        $nome = $data['nome']; // Assume que os dados são enviados em JSON
        $categoria = $data['categoria'];

        $sql = "INSERT INTO cliente (nome, categoria) VALUES ('$nome','$categoria')";
        if ($conn->query($sql) === TRUE) {
            if ($conn->affected_rows > 0) {
                $response['message'] = "Cliente adicionado com sucesso!";
            } else {
                $response['message'] = "Erro ao adicionar cliente: " . $conn->error;
            }
        }    
        break;
    case 'DELETE':            
        $id = $uri[4];// id indicado pela requisição PUT            
        // Atualiza o cliente no banco de dados
        $sql = "DELETE from cliente WHERE idcli='$id'";
        if ($conn->query($sql) === TRUE) {
            if ($conn->affected_rows > 0) {
                $response['message'] = "Cliente excluído com sucesso!";
            } else {
                $response['message'] = "Erro ao tentar excluir cliente: " . $conn->error;
            }
        }else
            $response['message'] = "Erro ao tentar excluir cliente: " . $conn->error;
        break;
    case 'GET':
        // Consulta de clientes
        $sql = "SELECT * FROM cliente";
        $result = $conn->query($sql);
        $response = array(); // Limpa a resposta anterior
        if ($result->num_rows > 0) {
            // Obtém os campos da consulta
            while ($row = $result->fetch_assoc()) {
                $response[] = ['id' => $row['idcli'], 'nome' => $row['nome'], 'categoria' => $row['categoria']];
            }
        } else {
            $response['message'] = "Método não permitido.";
        }
        break;
    default:
        $response['message'] = "Método não suportado.";
}

// Fecha a conexão com o banco de dados
$conn->close();

// Retorna a resposta em formato JSON
header('Content-Type: application/json');
echo json_encode($response);
