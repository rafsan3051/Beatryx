package app.lovable.serenessoundstudio;

import android.content.ComponentName;
import android.content.pm.PackageManager;
import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;

@CapacitorPlugin(name = "AppIcon")
public class AppIconPlugin extends Plugin {

    @PluginMethod
    public void changeIcon(PluginCall call) {
        String iconName = call.getString("icon");
        
        if (iconName == null) {
            call.reject("Icon name is required");
            return;
        }

        PackageManager packageManager = getActivity().getPackageManager();
        String packageName = getActivity().getPackageName();

        // Define the available icon aliases
        String[] iconAliases = {
            packageName + ".MainActivityDefault",
            packageName + ".MainActivityDisc"
        };

        // Determine which alias to enable
        String targetAlias;
        if ("disc-outline".equals(iconName)) {
            targetAlias = packageName + ".MainActivityDisc";
        } else {
            targetAlias = packageName + ".MainActivityDefault";
        }

        try {
            // Disable all aliases except the target
            for (String alias : iconAliases) {
                ComponentName componentName = new ComponentName(packageName, alias);
                int state = alias.equals(targetAlias) 
                    ? PackageManager.COMPONENT_ENABLED_STATE_ENABLED 
                    : PackageManager.COMPONENT_ENABLED_STATE_DISABLED;
                
                packageManager.setComponentEnabledSetting(
                    componentName,
                    state,
                    PackageManager.DONT_KILL_APP
                );
            }

            JSObject ret = new JSObject();
            ret.put("success", true);
            ret.put("icon", iconName);
            call.resolve(ret);
        } catch (Exception e) {
            call.reject("Failed to change icon: " + e.getMessage());
        }
    }

    @PluginMethod
    public void getCurrentIcon(PluginCall call) {
        PackageManager packageManager = getActivity().getPackageManager();
        String packageName = getActivity().getPackageName();

        ComponentName discComponent = new ComponentName(packageName, packageName + ".MainActivityDisc");
        int discState = packageManager.getComponentEnabledSetting(discComponent);

        String currentIcon = (discState == PackageManager.COMPONENT_ENABLED_STATE_ENABLED) 
            ? "disc-outline" 
            : "default";

        JSObject ret = new JSObject();
        ret.put("icon", currentIcon);
        call.resolve(ret);
    }
}
