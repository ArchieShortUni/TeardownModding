#include "script/common.lua"
pSpeed = GetFloatParam("speed", 0.2)
pfSpeed = GetFloatParam("speed", 3)

function init()
    raise = FindShape("raise", true)
    lower = FindShape("lower", true)

    forward = FindShape("forward", true)
    backward = FindShape("backward", true)

    detach = FindShape("break", true)
    
    SetTag(raise, "interact", "Raise")
    SetTag(lower, "interact", "Lower")

    SetTag(forward, "interact", "Forward")
    SetTag(backward, "interact", "Backward")

    SetTag(detach, "interact", "detach the panel")

    jladder = FindJoint("ladder", true)
    limitMin, limitMax = GetJointLimits(jladder) 
    jext = FindJoint("ext", true)
    flimitMin, flimitMax = GetJointLimits(jext) 

    j1 = FindJoint("panel1", true)
    j2 = FindJoint("panel2", true)

    forwardPressed = false
    backwardPressed = false
    
    raisedPressed = false
    lowerPressed = false

    backwardPressed = true
    press(backward)
end 

function press(shape)	
	s = GetShapeLocalTransform(shape)
	d = TransformToParentVec(s, Vec(0,-.05,0))
	s.pos = VecAdd(s.pos, d)
	SetShapeLocalTransform(shape, s)
    SetShapeEmissiveScale(shape, 20)
    
end 

function unpress(shape)
	s = GetShapeLocalTransform(shape)
	d = TransformToParentVec(s, Vec(0,.05,0))
	s.pos = VecAdd(s.pos, d)
	SetShapeLocalTransform(shape, s)
	SetShapeEmissiveScale(shape, 0)
	SetJointMotor(jladder, 0.0)
end

function unpressf(shape)
	s = GetShapeLocalTransform(shape)
	d = TransformToParentVec(s, Vec(0,.05,0))
	s.pos = VecAdd(s.pos, d)
	SetShapeLocalTransform(shape, s)
	SetShapeEmissiveScale(shape, 0)
    SetJointMotor(jext, 0.0)

end



function tick(dt) 
    local eps = 1
    if IsShapeOperated(lower) then
        if lowerPressed then
            unpress(lower)
            lowerPressed = false
        else 
            press(lower)
            lowerPressed = true

            if raisedPressed then 
                raisedPressed = false
                unpress(raise)
            end
        end
    end

    if IsShapeOperated(raise) then
        if raisedPressed then
            unpress(raise)
            raisedPressed = false
        else 
            press(raise)
            raisedPressed = true
            if lowerPressed then
                lowerPressed = false
                unpress(lower)
            end
        end
    end
    
    if lowerPressed then
        SetJointMotor(jladder, pSpeed)
        if GetJointMovement(jladder) < limitMin+eps then
            unpress(lower)
            lowerPressed = false
        end
    end
    if raisedPressed then
        SetJointMotor(jladder, -pSpeed)
        if GetJointMovement(jladder) > limitMax-eps then
            unpress(raise)
            raisedPressed = false
        end
    end


    if IsShapeOperated(backward) then
      if backwardPressed then
         unpressf(backward)
            backwardPressed = false
     else 
            press(backward)
           backwardPressed = true
           if forwardPressed then
             forwardPressed = false
              unpressf(forward)
            end
        end
    end

    if IsShapeOperated(forward) then
        if forwardPressed then
            unpressf(forward)
            forwardPressed = false
        else
            press(forward)
            forwardPressed = true
            if backwardPressed then
                backwardPressed = false
                unpressf(backward)
            end
        end
    end

    if backwardPressed then
        SetJointMotor(jext, pfSpeed)
        if GetJointMovement(jext) < flimitMin then
            unpressf(backward)
            backwardPressed = false
        end
    end

    if forwardPressed then
        SetJointMotor(jext, -pfSpeed)
        if GetJointMovement(jext) > flimitMin + 10.5 then
            unpressf(forward)
            forwardPressed = false
        end
    end

    if IsShapeOperated(detach) then
        Delete(j1)
        Delete(j2)
        Delete(detach)
    end
end 

