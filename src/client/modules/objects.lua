Core.Objects = {




  Create = function(modelname, pos, network, cb)
    local model = GetHashKey(modelname)
    while not HasModelLoaded(model) do RequestModel(model) Wait(0); end
    local obj = CreateObject(model, pos.x,pos.y,pos.z,network,true, false)
    SetEntityHeading(obj, (pos['w'] or 0.0))
    cb(obj)
  end,

  Delete = function(ent)
    DeleteEntity(ent)
  end,
}