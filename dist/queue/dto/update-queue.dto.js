"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.UpdateQueueDto = void 0;
const mapped_types_1 = require("@nestjs/mapped-types");
const create_queue_dto_1 = require("./create-queue.dto");
class UpdateQueueDto extends (0, mapped_types_1.PartialType)(create_queue_dto_1.CreateQueueDto) {
}
exports.UpdateQueueDto = UpdateQueueDto;
//# sourceMappingURL=update-queue.dto.js.map