from libdesklets.controls import Interface, Permission

class IExec(Interface):
    
    command = Permission.READWRITE
    result = Permission.READ
    output = Permission.READ
