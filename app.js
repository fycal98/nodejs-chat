const app = require('express')()
const {addUser,delUser,getUserslist} = require('./users')

const http = require('http')
const server = http.createServer(app)
const io = require('socket.io')(server)



io.on('connection',(socket)=>{
    
console.log('new connection')


socket.on('join',(data,)=>{
    const {username,room} = JSON.parse(data)
    const error = addUser({id:socket.id,username,room})
    if(error.error){
        return socket.emit('joineresponce',{error:'error'})
    }
    socket.join(room,()=>{
         
    
    socket.emit('joineresponce',{ok:'ok'})
    io.to(room).emit('users',getUserslist(room).map((element)=>{return element.username}))
    socket.broadcast.to(room).emit('newuser',username)

    })
    
    socket.on('unjoin',()=>{
        console.log('leaving room')
        socket.leaveAll()
        socket.emit('unjoined')
        socket.broadcast.to(room).emit('userleft',username)
        delUser(socket.id)
        socket.broadcast.emit('users',getUserslist(room).map((element)=>{return element.username}))
    })
})
    
   








    socket.on('sendmsg',(data)=>{
        const parseddata = JSON.parse(data)
        console.log(parseddata)
        io.to(parseddata.room).emit('receivemsg',{msg:parseddata.msg,sender:parseddata.sender})
    })
    

    socket.on('msg',(msg)=>{
        
        io.emit('sendedmsg',msg)
    })
    })





server.listen(8080,()=>{
    console.log('started listning on port 8080')
})








