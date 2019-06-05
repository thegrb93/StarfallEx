--@name Simple Moving Hologram
--@author Name
--@shared


// only do stuff on the serverside, we could also change --@shared to --@server
if SERVER then
    
    // Note that everything we do here works like if(first()) on expression 2, later in the code we'll add so-called hooks or timers that refresh our code
    // so everything written here line defining chip (its like entity()) in E2 is executed only once, but unlike in E2 we don't have to add it to @persist
    // each definition here will be remembered through-out the whole code, we can also do 'local variable' without the equal sign and any value provided
    // to just make space for this variable and set it later
    
    // assign our chip entity to 'c'
    local c = chip()
    
    // define our holo and assign it to variable 'holo'
    // at position of our entity, angle 0,0,0, with model of default E2 holo cube and scale 1.2
    local holo = holograms.create(c:getPos(), Angle(), "models/holograms/cube.mdl", Vector(1.2))
    
    // now lets change the hologram color so its not boring-white
    holo:setColor(Color(128,0,255)) // i just realised the model is a cube and color wont make it super-fun suddenly, shut up you
    
    // parent our hologram to the chip
    holo:setParent(c)
    
    // set our hologram angle velocity to 0,100,0
    // NOTE: this isnt using any cpu time, this is constant velocity, we set it only once you can do same with position as well (very good for constantly rotating stuff without using resources)
    holo:setAngVel(Angle(0,100,0))
    
    // lets define a simple function to update our holo
    local function myFunc()
        
        // you have different libraries like timer math and so on
        // but function names are very simmilar to those in E2
        // find all the libraries in the helper or on Gmod wiki
        
        // using the timer library, we're getting a current time (single number), lets multiply it so its a bit faster
        local curtime = timer.curtime()*2
        
        // using the math library we're using trigonometric function sinus (you are probably familiar with it already) and we pass in curtime
        // we're also multiplying this by 30 so it will move -30 to 30 G-Units
        local sin = math.sin(curtime)*30
        
        // now lets set position of our hologram to our chip pos (defined as 'c') + the sin we've created in the Y direction
        holo:setPos(c:getPos() + Vector(0,sin,0))
        
    end
    
    
    // we're now creating our hook, its basically equivelent of some way to refresh E2
    // you can find different hooks like PlayerSay KeyPress and others in the SF Helper (top right corner)
    // this one (think) will execute every physics update, to simplify its basically a runOnTick(1) and don't worry to use that in Starfall
    // we also define a name (its required but can be and empty string) so we can delete it later
    // we pass the function we've previously created, it will be executed when hook fires
    hook.add("tick", "custom_name", myFunc)
    
    
    
    
    // this is the simplest timer possible it will execute only once and remove itself, you can do more complex timers using timer.create(name, delay, repeats (0 - inf, func)
    // we're also gonna pass anonymous function, its just like a normal function we've created earlier to update our holo, but we can just write it in-line and we dont need to give it a name
    // also timer delays are in seconds
    timer.simple(3, function()
        
        // lets now remove our update hook so it will no longer move using our sin
        hook.remove("tick", "custom_name")
        
        // lets create a more complex timer now using timer.create() instead of timer.simple(), also with in-line function
        // i specify the name, delay and how many times to repeat, then function in which i write what to do on execution
        timer.create("lololo", 0.5, 6, function()
            
            // lets just move our holo up every 0.5s, 6 times total, whatever
            
            // getting position of my hologram, then getting it's up direction multiplied by 10
            holo:setPos(holo:getPos() + holo:getUp()*10)
            
        end)
        
    end) // dont forget this bracket here, since we're ending timer.simple()
    
    
end
