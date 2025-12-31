import { Filesystem, Directory } from '@capacitor/filesystem';

/**
 * Request storage permission with fallback
 */
export async function requestStoragePermission(): Promise<boolean> {
  try {
    // For Android 6+, we need to handle runtime permissions
    // This is handled at the Capacitor level, but we ensure graceful fallback
    
    // Try accessing files - if it works, permission is granted
    // If it fails, permission is denied
    const hasAccess = await checkStorageAccess();
    return hasAccess;
  } catch (err) {
    console.error('Permission check failed:', err);
    // On web or if permission system not available, assume granted
    return true;
  }
}

/**
 * Check if we have storage access by trying to list a directory
 */
async function checkStorageAccess(): Promise<boolean> {
  try {
    // Try to access downloads directory
    // This will fail if permission is not granted
    await Filesystem.readdir({
      path: 'Downloads',
      directory: Directory.ExternalStorage,
    });
    return true;
  } catch (err) {
    console.error('Storage access check failed:', err);
    return false;
  }
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
