local typedefs = require "kong.db.schema.typedefs"


local PLUGIN_NAME = "myplugin"


local schema = {
  name = PLUGIN_NAME,
  fields = {
    -- the 'fields' array is the top-level entry with fields defined by Kong
    { consumer = typedefs.no_consumer },  -- this plugin cannot be configured on a consumer (typical for auth plugins)
    { protocols = typedefs.protocols_http },
    { config = {
        -- The 'config' record is the custom part of the plugin schema
        type = "record",
        fields = {
          {
            limits = {
              type = "map",
              required = true,
              len_min = 1,
              keys = { type = "string" },
              values = {
                type = "record",
                required = true,
                fields = {
                  { second = { type = "number", gt = 0 }, },
                  { minute = { type = "number", gt = 0 }, },
                  { hour = { type = "number", gt = 0 }, },
                  { day = { type = "number", gt = 0 }, },
                  { month = { type = "number", gt = 0 }, },
                  { year = { type = "number", gt = 0 }, },
                }
              }
            }
          },
          -- a standard defined field (typedef), with some customizations
          { request_header = typedefs.header_name {
              required = true,
              default = "Hello-World" } },
          { response_header = typedefs.header_name {
              required = true,
              default = "Bye-World" } },
          { ttl = { -- self defined field
              description = "A map that defines rate limits for the plugin.",
              type = "integer",
              default = 600,
              required = true,
              gt = 0, }}, -- adding a constraint for the value
        },
        entity_checks = {
          -- add some validation rules across fields
          -- the following is silly because it is always true, since they are both required
          { at_least_one_of = { "request_header", "response_header" }, },
          -- We specify that both header-names cannot be the same
          { distinct = { "request_header", "response_header"} },
        },
      },
    },
  },
}

return schema
