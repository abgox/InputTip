use std::fs;
use std::path::Path;
use std::process::Command;

fn main() {
    let args: Vec<String> = std::env::args().collect();

    if args.len() < 3 {
        eprintln!("Usage: {} <process_name> <target_exe_path>", args[0]);
        std::process::exit(1);
    }

    let process_name = &args[1];
    let target_exe_path = &args[2];

    // 终止当前正在运行的 InputTip 进程
    Command::new("taskkill")
        .args(&["/f", "/im", process_name])
        .status()
        .expect("Failed to execute taskkill");

    // 将新版本的 exe 文件复制到目标路径
    let new_version_path = Path::new(&std::env::var("APPDATA").unwrap()).join("abgox-InputTip-new-version.exe");
    fs::copy(&new_version_path, target_exe_path).expect("Failed to copy new version");

    // 删除源文件
    fs::remove_file(&new_version_path).expect("Failed to delete source file");

    // 创建一个 txt 文件，用于标记更新完成
    let done_file_path = format!("{}\\.abgox-InputTip-update-version-done.txt", std::env::var("APPDATA").unwrap());
    fs::write(done_file_path, "").expect("Failed to create done file");

    // Run the target executable
    Command::new(target_exe_path)
        .spawn()
        .expect("Failed to start target executable");
}
