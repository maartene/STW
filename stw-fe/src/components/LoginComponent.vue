<template>
    <div>
        <div class="alert alert-warning d-flex align-items-center alert-dismissible fade show" role="alert" v-if="warningMessage != ''">
            <img src="/img/bootstrap-icons/exclamation-circle.svg" alt="Exclamation circle">&nbsp;&nbsp;
            <div>
                {{warningMessage}}
                <button type="button" class="btn-close" v-on:click="warningMessage = ''" aria-label="Close"></button>
            </div>
        </div>
        <div class="row">
            <div class="col-md p-3 mx-3 border">
                <h2>Login</h2>
                <form @submit.prevent="login">
                    <div class="form-group">
                    <label for="email" class="form-label">Email address:</label>
                    <input type="text" v-model="email" class="form-control" id="email" aria-describedby="emailHelp">
                    <div class="form-text" id="emailHelp">The email you used when signing up.</div>
                </div>
                <div class="form-group">
                    <label for="password" class="form-label">Password:</label>
                    <input type="password" v-model="password" class="form-control" id="password" aria-describedby="passwordHelp">
                    <div class="form-text" id="passwordHelp">You should have written this down...</div>
                </div>

                <button type="submit" class="btn btn-primary mb-3">Submit</button>
                </form>
            </div>
            <div class="col-md p-3 mx-3 border">
                <h2>Register</h2>
                <p>You will be assigned a country automatically after registering.</p>
                <form @submit.prevent="register">
                    <div class="form-group">
                        <label for="register-email" class="form-label">Email address:</label>
                        <input type="text" v-model="registerEmail" class="form-control" id="register-email" aria-describedby="register-emailHelp">
                        <div class="form-text" id="register-emailHelp">The email you will use to sign in.</div>
                    </div>
                    <div class="form-group">
                        <label for="register-name" class="form-label">Name:</label>
                        <input type="text" v-model="registerName" class="form-control" id="register-name" aria-describedby="register-nameHelp">
                        <div class="form-text" id="register-nameHelp">What do you want to be called in game?</div>
                    </div>                
                    <div class="form-group">
                        <label for="register-password" class="form-label">Password:</label>
                        <input type="password" v-model="registerPassword" class="form-control" id="register-password" aria-describedby="register-passwordHelp">
                        <div class="form-text" id="register-passwordHelp">Needs to be at least 8 characters long.</div>
                    </div>
                    
                    <div class="form-group">
                        <label for="register-confirmpassword" class="form-label">Confirm password:</label>
                        <input type="password" v-model="registerconfirmPassword" class="form-control" id="register-confirmpassword" aria-describedby="register-confirmpasswordHelp">
                        <div class="form-text" id="register-confirmpasswordHelp">Make sure its the same.</div>
                    </div>                
                    <button type="submit" class="btn btn-primary mb-3">Submit</button>
                    <p v-if="registerMessage">{{registerMessage}}</p>
                </form>            
            </div>
        </div>
    </div>
</template>

<script>
const axios = require('axios');

export default {
    name: "LoginComponent",
    data() {
        return {
            email: "",
            password: "",
            registerEmail: "",
            registerName: "",
            registerPassword: "",
            registerconfirmPassword: "",
            registerMessage: "",
            warningMessage: ""
        }
    },
    emits: ['login'],
    methods: {
        login() {
            const token = Buffer.from(`${this.email}:${this.password}`, 'utf8').toString('base64')
            axios.post(`${this.STW_API_ENDPOINT}/players/login/`, {}, {
                headers: {
                    'Authorization': `Basic ${token}` 
                }
            })
            .then(response => {
                //console.log(response.data)
                this.$emit('login', {
                    "token": response.data.value
                });
            })
            .catch(e => {
                this.warningMessage = `An error occured when loggin in: ${e}`
                //this.errors.push(e);
            })
        },
        register() {
            const create = {
                name: this.registerName,
                email: this.registerEmail,
                password: this.registerPassword,
                confirmPassword: this.registerconfirmPassword
            }
            //console.log(create);

            axios.post(`${this.STW_API_ENDPOINT}/players/`, create)
            .then(response => {
                console.log(response.data)
                this.registerMessage = response.data
            })
            .catch(e => {
                this.warningMessage = `An error occured when creating player: ${e}`
                //this.errors.push(e);
            })
        }
    }
}
</script>

<style>

</style>