express = require 'express'
app = express()

app.use express.static("#{__dirname}/public")

app.get '/', (req, res) -> res.sendfile("#{__dirname}/public/app/index.html")


app.listen 3000

console.log "app is listening on 0.0.0.0:3000"