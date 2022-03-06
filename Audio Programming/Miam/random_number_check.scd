(~randomiser={
var a, b, c, d, e;
	a = { [0,10, 20, 30,40,50,60,70,80,90,100].choose };
b = { 10.rand + 1 };
c = a + b;

 c.value;
})


(
var check;
check = if (~randomiser.value > 100, { "number is out of range" },{ ~randomiser.value+"is your random number" });
check.postln;
)


