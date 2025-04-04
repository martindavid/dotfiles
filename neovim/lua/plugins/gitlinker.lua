if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

local function stash_matcher(url_data)
  local url = "https://stash.atlassian.com/projects/"
  url = url .. "atlassian/repos/" .. url_data.repo:gsub("%.git", "")
  url = url .. "/browse/" .. url_data.file
  -- url = url .. "?at=master" .. url_data.rev
  if url_data.lend then
    url = url .. "#" .. url_data.lstart .. "-" .. url_data.lend
  else
    url = url .. "#" .. url_data.lstart
  end
  return url
end

return {
  "linrongbin16/gitlinker.nvim",
  opts = function(_, opts)
    opts.router = {
      browse = {
        ["^bitbucket%-mirror%-au%.internal%.atlassian%.com"] = stash_matcher,
      },
      blame = {
        ["^bitbucket%-mirror%-au%.internal%.atlassian%.com"] = stash_matcher,
      },
      default_branch = {
        ["^bitbucket%-mirror%-au%.internal%.atlassian%.com"] = stash_matcher,
      },
    }
  end,
}
