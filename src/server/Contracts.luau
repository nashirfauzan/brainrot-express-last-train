-- Pure per-stop contract state machine. All physical checks live in Missions.
local C={}
local titles={'Parcel delivery','Passenger escort','Signal repair','Requested-species catch'}
function C.accept(index,stop)
 local kind=(index or 0)%4+1
 return {kind=kind,stop=stop,title=titles[kind],stage=0,reward=250+kind*100,target=1,done=false}
end
function C.act(a,event,stop,id)
 -- Reject stale and paid contracts before any event can advance their stage.
 if not a or a.done or a.stop~=stop then return false end
 if a.kind==1 or a.kind==2 then
  local pickup=a.kind==1 and 'parcel' or 'passenger'
  if event==pickup and a.stage==0 then a.stage=1;return false end
  if event~='deliver' or a.stage~=1 then return false end
 elseif a.kind==3 then
  if event~='repair' then return false end
 elseif a.kind==4 then
  if event~='caught' or id~=a.target then return false end
 else return false end
 a.done=true;a.stage=2
 return true
end
return C
