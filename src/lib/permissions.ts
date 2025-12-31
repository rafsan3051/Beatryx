import { Filesystem, Directory } from '@capacitor/filesystem';

/**
 * Request storage permission - Capacitor handles this automatically
 */
export async function requestStoragePermission(): Promise<boolean> {
  // Always return true - permission is handled at Android OS level
  // If user denied, the file operations will fail
  return true;
}

/**
 * Check if we have storage access by trying to list a directory
 */
async function checkStorageAccess(): Promise<boolean> {
  // Try multiple paths to verify access
  const paths = ['Downloads', 'Music', ''];
  
  for (const path of paths) {
    try {
      await Filesystem.readdir({
        path,
        directory: Directory.ExternalStorage,
      });
      return true; // Success
    } catch (err) {
      continue; // Try next
    }
  }
  
  return false;
}

/**
 * Check if we have storage permission
 */
export async function hasStoragePermission(): Promise<boolean> {
  try {
    return await checkStorageAccess();
  } catch (err) {
    console.error('Storage permission check error:', err);
    return true; // Assume granted
  }
}
