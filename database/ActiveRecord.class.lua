--[[
                                       _ 
                                      | |
  _ __   _____      _____ _ __ ___  __| |
 | '_ \ / _ \ \ /\ / / _ \ '__/ _ \/ _` |
 | |_) | (_) \ V  V /  __/ | |  __/ (_| |
 | .__/ \___/ \_/\_/ \___|_|  \___|\__,_|
 | |                                                                              
 | |__  _   _   
 | '_ \| | | |  https://github.com/sanyisasha
 | |_) | |_| |  @Author SaSha <Molnár Sándor>
 |_.__/ \__, |
     _____/  /   _____  _           
    / ______/   / _____| |          
   | (___   __ _| (___ | |__   __ _ 
    \___ \ / _` |\___ \| '_ \ / _` |
    ____) | (_| |____) | | | | (_| |
   |_____/ \__,_|_____/|_| |_|\__,_|
]]


class "ActiveRecord" ("Object") {
    table = '',
    attributes = {},
    attributeKeys = {},
    originalAttributes = {},

    primaryKey = 'id',

    filled = false,
    isNew = true,
    __class = nil,

    __init__ = function(self)
        self.attributes = {}
        self.attributeKeys = {}
        self.originalAttributes = {}
        self:setAttributes()
    end,

    setAttributes = function(self)
        local attrs = Query():getSchema(self.table)
        for i,v in pairs(attrs) do
            table.insert(self.attributes, v['value'])
        end

        self.attributeKeys = array_keys(self.attributes)
    end,

    setOriginalAttributes = function(self)
        for i,v in pairs(self.attributes) do
            self.originalAttributes[v] = self[v]
        end
    end,

    getDirtyAttributes = function(self)
        local dirty = nil
        for i,v in pairs(self.attributes) do
            if self[v] ~= self.originalAttributes[v] then
                if not dirty then dirty = {} end
                dirty[v] = true
            end
        end

        return dirty
    end,

    fill = function(self, datas)
        if self.filled then return end
        if datas then
            for i,v in pairs(datas) do
                if not v then v = '' end
                self[i] = v
                table.insert(self.attributes, i)
            end
            self.filled = true
        end
    end,

    getQuery = function(self)
        return Query():select():from(self.table)
    end,

    loadByQuery = function(self, modelDatas, returnOne)
        if not modelDatas then return nil end

        local models = {}
        if not returnOne then returnOne = false end
        
        if modelDatas[self.primaryKey] then -- :one()
            returnOne = true
            modelDatas = {["1"] = modelDatas}
        end

        for i,v in pairs(modelDatas) do
            local model = self.__class()
            model:fill(v)
            if model.init then model:init() end
            model:setOriginalAttributes()
            model.isNew = false
            if model.afterFind then model:afterFind() end
            if returnOne then return model end
            models[model[model.primaryKey]] = model
        end


        return models
    end,

    findOne = function(self, id)
        local data = Query():select():from(self.table):where({id = id}):one()
        self:fill(data)
        if self.init then self:init() end
    
        self:setOriginalAttributes()

        self.isNew = false
        return self
    end,

    findAll = function(self, conditions)
        local q = Query():select():debug(true):from(self.table)
        if conditions then
            q:where(conditions)
        end
        local result = q:all()
        return self:loadByQuery(result)
    end,

    save = function(self, force)
        if not force then force = false end
        if not self.isNew and self.beforeSave then self:beforeSave() end

        if not force and not self.isNew and not self:getDirtyAttributes() then
            outputDebugString(self.__name__..'#'..self.id..' unchanged.', 2)
            return true
        end
        local datas = {}
        for i,v in pairs((self.isNew or force) and self.attributeKeys or self:getDirtyAttributes()) do
            if self[i] then
                datas[i] = self[i]
            end
        end

        if self.attributeKeys.updated_at then datas['updated_at'] = getDateTime() end

        if not self.isNew then
            local condition = {}
            condition[self.primaryKey] = self[self.primaryKey]
            
            if self.beforeUpdate then self:beforeUpdate() end
            local update = Query():update(self.table, datas, condition)
            if self.afterUpdate then self:afterUpdate() end
            if self.afterSave then self:afterSave() end
            return update
        else
            if self.attributeKeys.created_at then datas['created_at'] = getDateTime() end
            if self.beforeInsert then self:beforeInsert() end
            local _,_,id = Query():insert(self.table, datas)
            if self.afterInsert then self:afterInsert() end
            if self.afterSave then self:afterSave() end
            return self:findOne(id)
        end
    end,

    delete = function(self)
        if self.beforeDelete then self:beforeDelete() end

        local condition = {}
        condition[self.primaryKey] = self[self.primaryKey]
        if Query():delete(self.table, condition) then
            if self.afterDelete then self:afterDelete() end
            self = nil

            return true
        end
        return false
    end,

    deleteOne = function(self, id)
        local condition = {}
        condition[self.primaryKey] = id
        return Query():delete(self.table, condition)
    end,

    deleteAll = function(self, condition)
        return Query():delete(self.table, condition)
    end,

    updateOne = function(self, id, values)
        local condition = {}
        condition[self.primaryKey] = id
        return Query():update(self.table, values, condition)
    end,

    updateAll = function(self, condition, values)
        return Query():update(self.table, values, condition)
    end,

    refresh = function(self)
        return self:findOne(self[self.primaryKey])
    end,
}