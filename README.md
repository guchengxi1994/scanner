# scanner

a simple tool to search files or folders

## changelog

* 3.0.0 (WIP):
  * 重构桌面端应用壳层和导航，新增首页、大文件扫描、重复文件扫描、扫描任务和设置页面。
  * 增加自定义标题栏，支持拖动窗口、最小化、最大化和关闭；窗口尺寸限制为 1064 x 852。
  * 大文件/文件夹扫描改为单次遍历和增量进度推送，降低磁盘重复读取和前端刷新压力。
  * 重复文件扫描改为“文件大小分桶 -> 前 1MB 快速哈希 -> 候选文件五点采样 SHA-256”流程；同一路径指纹通过带修改时间校验的全局缓存复用。采样策略用于快速筛选，未采样区域差异可能需要人工复核。
  * 重复扫描增加候选验证进度、持续状态反馈和重复组增量展示，避免长时间任务被误认为卡死。
  * 重复文件完整校验阶段实时推送当前候选组路径，状态卡展示正在比对的文件。
  * 设置页支持新增和删除排除规则，支持目录名、通配符和正则表达式；规则作用于大文件、重复文件和文档检索遍历。
  * 使用 Isar Community 保存最近 30 次扫描历史，应用重启后仍可在“扫描任务”中查看。
  * 接入 `package_info_plus`，前端显示实际应用名称和版本信息。
  * 增加 AnyDoc 文档内容检索实验功能，支持在本机检索受支持文档的内容。
  * 优化首页概览、快速操作、最近任务、扫描状态和空状态页面的布局与视觉反馈。

* 2.1.0 (unreleased):
  
  * inspect child folder

* 2.0.0:
  
  * caculate folder size and draw treemap

    ![image-20241129165523838](image-20241129165523838.png)
  
* 1.2.2:
  * add progress bar

* 1.2.1 (unreleased):
  * hash function changed

* 1.2.0 (unreleased):
  * refactor rust `Event`

* 1.1.1+1 (unreleased):
  * add some callbacks
  * performance improvement
  * add `PaginatorController`

* 1.1.1: 
  * remove item from list when remove button clicked

* 1.1.0 (unreleased): 
  * add `remove` and `openfile` button

* 1.0.0: initial release
