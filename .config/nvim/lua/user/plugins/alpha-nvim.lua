return {
  {
    "goolord/alpha-nvim",
    opts = function(_, opts)
      -- customize the dashboard header
      -- https://patorjk.com/software/taag/#p=display&f=Slant&t=PALILO%0ANEOVIM
      opts.section.header.val = {
        "     ____  ___    __    ______    ____  ",
        "    / __ \\/   |  / /   /  _/ /   / __ \\ ",
        "   / /_/ / /| | / /    / // /   / / / / ",
        "  / ____/ ___ |/ /____/ // /___/ /_/ /  ",
        " /_/_  /_/__|_/_____/___/_____/\\____/__",
        "   / | / / ____/ __ \\ |  / /  _/  |/  /",
        "  /  |/ / __/ / / / / | / // // /|_/ / ",
        " / /|  / /___/ /_/ /| |/ // // /  / /  ",
        "/_/ |_/_____/\\____/ |___/___/_/  /_/   ",
      }
      return opts
    end,
  },
}

