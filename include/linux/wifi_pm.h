#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/init.h>
#include <linux/moduleparam.h>

int wifi_pm = 0;
module_param(wifi_pm, int, 0755);
EXPORT_SYMBOL(wifi_pm);
