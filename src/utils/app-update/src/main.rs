use std::process::Command;
use std::{env, fs};

fn main() {
    let args: Vec<String> = std::env::args().collect();

    if args.len() < 4 {
        eprintln!(
            "Usage: {} <process_name> <target_exe_path> <key_count>",
            args[0]
        );
        std::process::exit(1);
    }

    let process_name = &args[1];
    let target_exe_path = &args[2];
    let key_count = &args[3];
    let dir = env::current_dir()
        .expect("Failed to get current directory")
        .join("InputTipSymbol")
        .join("default");

    // 终止当前正在运行的 InputTip 进程
    Command::new("taskkill")
        .args(&["/f", "/im", process_name])
        .status()
        .expect("Failed to execute taskkill");

    // 将新版本的 exe 文件复制到目标路径
    let new_version_path = dir.join("abgox-InputTip-new-version.exe");
    fs::copy(&new_version_path, target_exe_path).expect("Failed to copy new version");

    // 删除源文件
    fs::remove_file(&new_version_path).expect("Failed to delete source file");

    // 创建一个 txt 文件，用于标记更新完成
    let done_file_path = dir.join("abgox-InputTip-update-version-done.txt");
    fs::write(done_file_path, "").expect("Failed to create done file");

    // 运行 InputTip.exe
    Command::new(target_exe_path)
        .arg(key_count)
        .spawn()
        .expect("Failed to start target executable");
}
