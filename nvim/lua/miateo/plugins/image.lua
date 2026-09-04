return {
    "3rd/image.nvim",
    event = "VeryLazy",
    opts = {
        backend = "kitty",
        processor = "magick_cli",
        integrations = {
            markdown = {
                enabled = true,
                clear_in_insert_mode = false,
                download_remote_images = true,
                only_render_image_at_cursor = false,
                filetypes = { "markdown", "md", "norg" },
            },
        },
        max_width = 120,
        max_height = 30,
        window_overlap_clear_enabled = true,
    },
}
