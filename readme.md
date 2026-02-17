# following log is a FALSE-POSITIVE
this is caused because zgui library uses some c library that uses static and zig checks before defering the memory
`info: [zgui] Possible memory leak or static memory usage detected: (address: 0x282cfc50, size: 128)`
