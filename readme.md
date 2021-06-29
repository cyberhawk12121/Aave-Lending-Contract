So, we have 2 tokens
One that the investors will invest in like some USD or some shit.
The other is our own cryptocurrency that they'll get back as interest.

What we do is that we put all the money in the contract (some kinda pool) then 
the smart contract will organize that cash pool.


### Approve and Transfer Functions
The `approve` + `transferFrom` is for a 3rd party transfer, usually, but not necessarily that of an exchange, where the sender wishes to authorise a second party to transfer some tokens on their behalf.

Sender ➜ `approve(exchange, amount)`
Buyer ➜ `executes trade on the Exchange`
Exchange ➜ `transferFrom(sender, buyer, amount)`