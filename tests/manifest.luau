return function(E)
 local s = E.new()
 local cargo = {id=1, mutation=1, rate=8}
 assert(E.catch(s,cargo), 'first catch fits')
 assert(not E.catch(s,cargo), 'carry cap')
 assert(E.tick(s)==0, 'unsecured catches cannot earn')
 assert(E.bank(s)==1, 'deposit moves one catch')
 assert(E.tick(s)==8 and s.cash==8, 'one second of banked income')
 assert(E.catch(s,cargo), 'deposit frees carry')
 assert(E.depart(s)==1 and #s.bank==1 and #s.carry==0, 'only unsecured catch is lost')
end
