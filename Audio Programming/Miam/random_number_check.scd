(~randomiser={// a function as global variable
var a, b, c;
	a = { [0,10, 20, 30,40,50,60,70,80,90,100].choose }; // A function that chooses random value of an array
b = { 10.rand + 1 }; // a function that chooses a random number up to 10 and adds 1
c = a + b; // adding two function values

 c.value; // returning the final value
})

/////////////////////////////////////////////////////////////

(
var check; // a variable
check = if (~randomiser.value > 100, { "number is out of range" },{ ~randomiser.value+"is your random number" }); // this variableis defined with a statement which checks if the randomiser function returns a value higher than 100
check.postln; // prints the output of the statement in a readable form at post window
)
