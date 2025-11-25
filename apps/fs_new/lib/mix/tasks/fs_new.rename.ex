defmodule Mix.Tasks.FsNew.Rename do
  use Igniter.Mix.Task

  @example "mix fs_new.rename event_playground"
  @shortdoc "Rename the FireStarter umbrella project to a new name"

  @moduledoc """
  #{@shortdoc}

  Performs an in-place rename of the entire FireStarter umbrella project, including:
  - All Elixir modules and atomProject renamed successfullys
  - Configuration files
  - Templates and assets
  - Docker and deployment configurations
  - Documentation
  - Directory names

  The task preserves git history by renaming files in place.

  ## Example

  ```bash
  #{@example}
  ```

  This will rename:
  - `FireStarter` → `EventPlayground` (modules)
  - `fire_starter` → `event_playground` (atoms/directories)
  - `fire-starter` → `event-playground` (URLs/deployment)
  - `FIRE_STARTER` → `EVENT_PLAYGROUND` (environment variables)

  ## Post-Rename Steps

  After running this task, you'll need to:
  1. Run `mix setup`
  2. Update git remote URL if needed
  3. Run `mix test` to verify everything works
  """

  @impl Igniter.Mix.Task
  def supports_umbrella?, do: true

  @impl Igniter.Mix.Task
  def info(_argv, _composing_task) do
    %Igniter.Mix.Task.Info{
      group: :fire_starter,
      example: @example,
      positional: [:new_name],
      schema: []
    }
  end

  @impl Mix.Task
  def run(argv) do
    # Parse the new name from arguments early
    new_name = List.first(argv)

    # Run the parent implementation which handles all file updates
    super(argv)

    # After Igniter completes, rename directories, files, and subdirectories
    if new_name && new_name != "" && !Enum.member?(argv, "--dry-run") do
      rename_directories_with_git(new_name)
      rename_files_and_subdirs(new_name)
    end
  end

  @impl Igniter.Mix.Task
  def igniter(igniter) do
    new_name = igniter.args.positional[:new_name]

    if is_nil(new_name) || new_name == "" do
      igniter
      |> Igniter.add_issue(
        "You must provide a new project name. Example: mix fs.rename event_playground"
      )
    else
      case validate_name(new_name) do
        :ok ->
          igniter
          |> rename_project(new_name)
          |> add_completion_notice()

        {:error, reason} ->
          Igniter.add_issue(igniter, reason)
      end
    end
  end

  defp validate_name(name) do
    # Check if it's a valid Elixir identifier (snake_case)
    if Regex.match?(~r/^[a-z][a-z0-9_]*$/, name) do
      :ok
    else
      {:error,
       "Project name must be a valid Elixir identifier in snake_case (e.g., 'event_playground')"}
    end
  end

  defp rename_project(igniter, new_name) do
    # Generate all naming variants
    names = %{
      # New names
      snake: new_name,
      pascal: snake_to_pascal(new_name),
      kebab: String.replace(new_name, "_", "-"),
      screaming: String.upcase(new_name),
      # Old names
      old_snake: "fire_starter",
      old_pascal: "FireStarter",
      old_kebab: "fire-starter",
      old_screaming: "FIRE_STARTER"
    }

    igniter
    |> rename_elixir_files(names)
    |> rename_template_files(names)
    |> rename_asset_files(names)
    |> rename_config_files(names)
    |> rename_deployment_files(names)
    |> rename_documentation_files(names)
  end

  defp rename_elixir_files(igniter, names) do
    # Update all .ex and .exs files using string replacement
    # This approach works well for renaming as it preserves all code structure
    update_files_by_glob(igniter, "**/*.{ex,exs}", names)
  end

  defp rename_template_files(igniter, names) do
    # Update all .heex template files
    update_files_by_glob(igniter, "**/*.heex", names)
  end

  defp rename_asset_files(igniter, names) do
    # Update asset files
    globs = [
      "apps/*/assets/**/*.{js,css,json,ts}",
      "apps/*/assets/tsconfig.json"
    ]

    Enum.reduce(globs, igniter, fn glob, acc ->
      update_files_by_glob(acc, glob, names)
    end)
  end

  defp rename_config_files(igniter, _names) do
    # Config files are Elixir files, already handled by rename_elixir_files
    igniter
  end

  defp rename_deployment_files(igniter, names) do
    # Update deployment-related files
    globs = [
      "apps/*/fly.toml",
      "apps/*/Dockerfile",
      "docker-compose.yaml",
      ".env.template",
      ".github/workflows/*.yml",
      "apps/*/rel/overlays/bin/*",
      "script/**/*",
      "conductor.json"
    ]

    Enum.reduce(globs, igniter, fn glob, acc ->
      update_files_by_glob(acc, glob, names)
    end)
  end

  defp rename_documentation_files(igniter, names) do
    # Update documentation
    globs = [
      "README.md",
      "guides/**/*.md",
      ".ecto_erd.exs",
      "apps/*/.gitignore"
    ]

    Enum.reduce(globs, igniter, fn glob, acc ->
      update_files_by_glob(acc, glob, names)
    end)
  end

  # Helper function to update files by glob pattern
  defp update_files_by_glob(igniter, glob, names) do
    Path.wildcard(glob, match_dot: true)
    |> Enum.reduce(igniter, fn path, acc ->
      if should_update_file?(path) do
        update_file_content(acc, path, names)
      else
        acc
      end
    end)
  end

  # Check if a file should be updated (skip templates and generated files)
  defp should_update_file?(path) do
    cond do
      !File.exists?(path) || !File.regular?(path) ->
        false

      String.contains?(path, ["deps/", "_build/", "apps/fs_new/"]) ->
        false

      # Skip actual EEx template files (in priv/templates directories)
      String.contains?(path, "/priv/templates/") ->
        false

      true ->
        true
    end
  end

  # Helper function to update a single file's content
  defp update_file_content(igniter, path, names) do
    Igniter.update_file(igniter, path, fn source ->
      content = Rewrite.Source.get(source, :content)

      updated_content = apply_name_replacements(content, names)

      Rewrite.Source.update(source, :content, updated_content)
    end)
  end

  # Apply all name replacements in the correct order
  defp apply_name_replacements(content, names) do
    content
    # Replace Web variants first to avoid double-replacement
    |> String.replace(names.old_pascal <> "Web", names.pascal <> "Web")
    |> String.replace(names.old_snake <> "_web", names.snake <> "_web")
    |> String.replace(names.old_kebab <> "-web", names.kebab <> "-web")
    # Then replace base names
    |> String.replace(names.old_pascal, names.pascal)
    |> String.replace(names.old_snake, names.snake)
    |> String.replace(names.old_kebab, names.kebab)
    # Environment variables (with trailing underscore to avoid partial matches)
    |> String.replace(names.old_screaming <> "_", names.screaming <> "_")
    # Standalone environment variable (end of line or not followed by alphanumeric)
    |> String.replace(~r/#{names.old_screaming}(?![A-Z_])/, names.screaming)
  end

  defp add_completion_notice(igniter) do
    notice = """

    ✅ Project renamed successfully!

    📋 Next steps:
    1. Run `mix setup`
    2. Update git remote URL if needed
    3. Run `mix test` to verify everything works

    🔍 What was updated:
    - All Elixir source files (.ex, .exs)
    - All templates (.heex)
    - All assets (JS, CSS, JSON)
    - Configuration files
    - Deployment files (Dockerfile, fly.toml, etc.)
    - Documentation files
    - App directory names (automatically renamed)
    """

    Igniter.add_notice(igniter, notice)
  end

  # Convert snake_case to PascalCase
  defp snake_to_pascal(snake_case) do
    snake_case
    |> String.split("_")
    |> Enum.map_join(&String.capitalize/1)
  end

  # Rename directories using git mv (or regular mv as fallback)
  defp rename_directories_with_git(new_name) do
    old_snake = "fire_starter"
    new_snake = new_name

    # Get all apps directories except fs_new (this task's directory)
    dirs_to_rename =
      File.ls!("apps")
      |> Enum.filter(&(&1 != "fs_new" && String.starts_with?(&1, old_snake)))
      |> Enum.map(fn dir ->
        new_dir = String.replace(dir, old_snake, new_snake)
        {"apps/#{dir}", "apps/#{new_dir}"}
      end)

    if dirs_to_rename == [] do
      Mix.shell().info("\n⏭️  No directories to rename")
    else
      Mix.shell().info("\n🔄 Renaming directories...")
      Enum.each(dirs_to_rename, &rename_directory/1)
      Mix.shell().info("\n✅ Directory renaming complete!")
    end
  end

  defp rename_directory({old_dir, new_dir}) do
    cond do
      !File.exists?(old_dir) ->
        Mix.shell().info("  ⏭️  Skipped: #{old_dir} (doesn't exist)")

      git_mv_success?(old_dir, new_dir) ->
        Mix.shell().info("  ✅ Renamed: #{old_dir} → #{new_dir} (with git)")

      true ->
        fallback_rename(old_dir, new_dir)
    end
  end

  defp git_mv_success?(old_dir, new_dir) do
    case System.cmd("git", ["mv", old_dir, new_dir], stderr_to_stdout: true) do
      {_output, 0} -> true
      {_output, _} -> false
    end
  end

  defp fallback_rename(old_dir, new_dir) do
    case File.rename(old_dir, new_dir) do
      :ok ->
        Mix.shell().info("  ✅ Renamed: #{old_dir} → #{new_dir}")

      {:error, reason} ->
        Mix.shell().error("  ❌ Failed to rename #{old_dir}: #{inspect(reason)}")
    end
  end

  # Rename files and subdirectories within the renamed app directories
  defp rename_files_and_subdirs(new_name) do
    old_snake = "fire_starter"
    new_snake = new_name

    Mix.shell().info("\n🔄 Renaming files and subdirectories...")

    # Get all renamed app directories (they've already been renamed in rename_directories_with_git)
    File.ls!("apps")
    |> Enum.filter(fn dir ->
      dir != "fs_new" && String.starts_with?(dir, new_snake)
    end)
    |> Enum.each(fn app_dir ->
      app_path = "apps/#{app_dir}"
      rename_within_directory(app_path, old_snake, new_snake)
    end)

    Mix.shell().info("\n✅ File and subdirectory renaming complete!")
  end

  # Recursively rename files and directories within a given directory
  defp rename_within_directory(dir_path, old_name, new_name) do
    File.ls!(dir_path)
    |> Enum.reject(&(&1 in ["_build", "deps", ".git"]))
    |> Enum.each(&rename_item(dir_path, &1, old_name, new_name))
  end

  defp rename_item(dir_path, item, old_name, new_name) do
    old_path = Path.join(dir_path, item)

    if String.contains?(item, old_name) do
      rename_and_recurse(old_path, dir_path, item, old_name, new_name)
    else
      maybe_recurse(old_path, old_name, new_name)
    end
  end

  defp rename_and_recurse(old_path, dir_path, item, old_name, new_name) do
    new_item = String.replace(item, old_name, new_name)
    new_path = Path.join(dir_path, new_item)

    case File.rename(old_path, new_path) do
      :ok ->
        Mix.shell().info("  ✅ Renamed: #{old_path} → #{new_path}")
        maybe_recurse(new_path, old_name, new_name)

      {:error, reason} ->
        Mix.shell().error("  ❌ Failed to rename #{old_path}: #{inspect(reason)}")
    end
  end

  defp maybe_recurse(path, old_name, new_name) do
    if File.dir?(path), do: rename_within_directory(path, old_name, new_name)
  end
end
