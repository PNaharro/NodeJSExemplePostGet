const express = require('express');
const multer = require('multer');
const url = require('url');
const fetch = require('node-fetch');
// Importa la librería node-fetch

const app = express();
const port = process.env.PORT || 3000;

// Configurar la recepción de archivos a través de POST
const storage = multer.memoryStorage();
const upload = multer({ storage: storage });

app.use(express.static('public'));
app.use(express.json());

const httpServer = app.listen(port, appListen);

async function appListen() {
  console.log(`Listening for HTTP queries on: http://localhost:${port}`);
}

process.on('SIGTERM', shutDown);
process.on('SIGINT', shutDown);

function shutDown() {
  console.log('Received kill signal, shutting down gracefully');
  httpServer.close();
  process.exit(0);
}

app.get('/ieti', getIeti);

async function getIeti(req, res) {
  res.writeHead(200, { 'Content-Type': 'text/html' });
  res.end('<html><head><meta charset="UTF-8"></head><body><b>El millor</b> institut del món!</body></html>');
}

app.get('/llistat', getLlistat);

async function getLlistat(req, res) {
  let query = url.parse(req.url, true).query;

  if (query.cerca && query.color) {
    res.writeHead(200, { 'Content-Type': 'text/plain; charset=UTF-8' });
    res.write(`result: "Aquí tens el llistat de ${query.cerca} de color ${query.color}"`);
    res.write(`\n list: ["item0", "item1", "item2"]`);
    res.end(`\n end: "Això és tot"`);
  } else {
    res.status(400).json({ result: 'Paràmetres incorrectes' });
  }
}


app.post('/data', upload.single('file'), async (req, res) => {
  const textPost = req.body;
  const uploadedFile = req.file;
  let objPost = {};

  try {
    objPost = JSON.parse(textPost.data);
    console.log('Valor de "mensaje" recibido:');
    const pregunta = objPost.mensaje;
    console.log(pregunta);


    // Verifica si la solicitud a la otra API fue exitosa (código de estado 200)
    try {
      const response = await fetch('http://localhost:11434/api/generate', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          model: 'mistral',
          prompt: pregunta,
        }),
      });

      console.log('Código de estado de la respuesta de la otra API:', response.status);

      // Verifica si la solicitud a la otra API fue exitosa (código de estado 200)
      if (response.ok) {
        try {
          const responseBody = await response.json(); // Intenta analizar la respuesta como JSON

          // Imprime la respuesta completa
          console.log('Respuesta de la otra API (cuerpo completo):');
          console.log(responseBody);

          // Devuelve la clave 'response' como respuesta de tu servidor
          res.status(200).json({ response: responseBody });
        } catch (error) {
          // Si hay un error al analizar el JSON, imprime el error y devuelve un mensaje de error
          console.log('Error al analizar la respuesta JSON:', error);

          // Verifica si la respuesta no es un JSON válido
          if (error.type === 'invalid-json') {
            res.status(500).send('Error: La respuesta de la otra API no es un JSON válido');
          } else {
            res.status(500).send('Error interno al procesar la respuesta de la otra API');
          }
        }
      } else {
        // Si la respuesta no es exitosa, imprime el cuerpo de la respuesta
        const responseBody = await response.text();
        console.log('Respuesta de la otra API (cuerpo completo):', responseBody);

        res.status(response.status).send('Error en la solicitud a la otra API');
      }
    } catch (error) {
      res.status(400).send('Solicitud incorrecta.');
      console.log(error);
      return;
    }
  } catch (error) {
    res.status(400).send('Solicitud incorrecta.');
    console.log(error);
    return;
  }
});