export class Person {
    constructor(name) {
        this.name = name
    }

    hello() {
        console.log(`Hello, ${this.name}!`)
    }
}