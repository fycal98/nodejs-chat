let users = [{id:'id',username:'faissal',room:'room'}]

const  addUser = function(user){
    const index = users.findIndex((u)=>(user.username === u.username)&&(user.room === u.room))
    if(index !== -1){
        return {error  : 'error'}
    }
    users.push(user)
    return({})
}
const delUser = function (id){
    const index = users.findIndex((value)=>{
        return value.id === id
    })
    if(index !== -1){
        return users.splice(index,1)[0]
        
    }
}

const getUserslist = function (room){

    return users.filter((element)=>{

        if(element.room === room){
            return true
        }
        else return false
    })
}




module.exports = {addUser,delUser,getUserslist}
